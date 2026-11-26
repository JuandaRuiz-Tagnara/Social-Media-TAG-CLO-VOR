#!/usr/bin/env bash
# QA de audio para reels/videos — estándar Sonido Zimmer
# Uso: bash qa_audio.sh archivo.mp4 [--permitir-mudo]
# Sale con código 1 si alguna regla FALLA.
set -uo pipefail

f="${1:-}"; permitir_mudo="${2:-}"
[ -f "$f" ] || { echo "Uso: qa_audio.sh archivo.mp4 [--permitir-mudo]"; exit 2; }

fallas=0; advert=0
ok()   { printf "  [APROBADO]    %s\n" "$1"; }
warn() { printf "  [ADVERTENCIA] %s\n" "$1"; advert=$((advert+1)); }
bad()  { printf "  [FALLA]       %s\n" "$1"; fallas=$((fallas+1)); }
between() { awk -v x="$1" -v a="$2" -v b="$3" 'BEGIN{exit !(x>=a && x<=b)}'; }
le() { awk -v x="$1" -v y="$2" 'BEGIN{exit !(x<=y)}'; }

echo "QA SONIDO ZIMMER — $(basename "$f")"

info=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate,channels,bit_rate -of csv=p=0 "$f")
dur_v=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
if [ -z "$info" ]; then
  if [ "$permitir_mudo" = "--permitir-mudo" ]; then echo "  Sin audio (permitido explícitamente)."; exit 0; fi
  bad "Sin pista de audio. Si es intencional, usa --permitir-mudo"; echo "RESULTADO: FALLA"; exit 1
fi
IFS=, read -r codec sr ch br <<<"$info"
echo "  Stream: $codec · ${sr} Hz · ${ch} canales · $(( ${br:-0} / 1000 )) kbps · ${dur_v%.*} s"

# 1. Sample rate y canales
[ "$sr" = "48000" ] && ok "Sample rate 48 kHz" || bad "Sample rate ${sr} Hz (debe ser 48000)"
[ "$ch" = "2" ] && ok "Estéreo" || warn "Canales: $ch (se espera estéreo)"
if [ -n "${br:-}" ] && [ "$br" != "N/A" ] && [ "$br" -lt 190000 ]; then warn "Bitrate $(( br/1000 )) kbps (< 192)"; fi

# 2. Loudness
m=$(ffmpeg -nostats -i "$f" -vn -af loudnorm=print_format=json -f null - 2>&1)
I=$(echo "$m" | grep '"input_i"' | tr -dc '0-9.\-'); TP=$(echo "$m" | grep '"input_tp"' | tr -dc '0-9.\-'); LRA=$(echo "$m" | grep '"input_lra"' | tr -dc '0-9.\-')
between "$I" -15 -13 && ok "Loudness integrado ${I} LUFS (objetivo −14 ±1)" || bad "Loudness integrado ${I} LUFS (objetivo −14 ±1)"
le "$TP" -1.0 && ok "True peak ${TP} dBTP (≤ −1.0)" || bad "True peak ${TP} dBTP (> −1.0: riesgo de distorsión al recodificar)"
if between "$LRA" 4 8; then ok "LRA ${LRA} LU (respira, 4–8)"
elif between "$LRA" 3 10; then warn "LRA ${LRA} LU (aceptable, ideal 4–8)"
elif le "$LRA" 3; then bad "LRA ${LRA} LU: muro de sonido plano, sin arco"
else bad "LRA ${LRA} LU: demasiada dinámica para celular"; fi

# 3. Arranque (primeros 0.5 s)
rms_ini=$(ffmpeg -nostats -t 0.5 -i "$f" -vn -af astats -f null - 2>&1 | grep "RMS level dB" | tail -1 | awk '{v=$NF; if(v=="-inf")print v; else printf "%.1f", v}')
if [ "$rms_ini" = "-inf" ] || le "$rms_ini" -35; then bad "Arranque mudo/tibio (${rms_ini} dB RMS en 0.5 s): el gancho debe sonar desde el frame 1"
elif le "$rms_ini" -25; then warn "Arranque suave (${rms_ini} dB RMS). ¿Intencional?"
else ok "Arranque con presencia (${rms_ini} dB RMS)"; fi

# 4. Cierre: silencio sobrante y corte seco
win=3; st=$(awk -v d="$dur_v" -v w="$win" 'BEGIN{print (d>w)?d-w:0}')
sil=$(ffmpeg -nostats -ss "$st" -i "$f" -vn -af silencedetect=n=-50dB:d=0.2 -f null - 2>&1 | grep silence_start | tail -1 | sed -E 's/.*silence_start: *([0-9.]+).*/\1/')
rms_fin=$(ffmpeg -nostats -ss "$(awk -v d="$dur_v" 'BEGIN{print d-0.05}')" -i "$f" -vn -af astats -f null - 2>&1 | grep "RMS level dB" | tail -1 | awk '{v=$NF; if(v=="-inf")print v; else printf "%.1f", v}')
if [ -n "$sil" ]; then
  cola=$(awk -v d="$dur_v" -v st="$st" -v s="$sil" 'BEGIN{printf "%.2f", d-(st+s)}')
  if le 0.8 "$cola"; then bad "Silencio de ${cola} s al final (máx 0.8 s después de la firma; ventana medida ${win} s)"; else ok "Cierre limpio (silencio final ${cola} s)"; fi
elif [ "$rms_fin" != "-inf" ] && ! le "$rms_fin" -30; then
  warn "Últimos 50 ms a ${rms_fin} dB RMS: posible corte seco. Verifica que termine en el beat"
else ok "Cierre con cola/fade"; fi

# 5. Compatibilidad mono (parlante del celular)
Im=$(ffmpeg -nostats -i "$f" -vn -af "pan=mono|c0=0.5*c0+0.5*c1,loudnorm=print_format=json" -f null - 2>&1 | grep '"input_i"' | tr -dc '0-9.\-')
drop=$(awk -v a="$I" -v b="$Im" 'BEGIN{printf "%.1f", a-b}')
le "$drop" 4.5 && ok "Compatible en mono (caída ${drop} dB; 3.0 = mono puro)" || bad "Caída de ${drop} dB en mono: problema de fase o estéreo exagerado"

# 6. Duración audio vs video
dur_a=$(ffprobe -v error -select_streams a:0 -show_entries stream=duration -of csv=p=0 "$f")
if [ -n "$dur_a" ] && [ "$dur_a" != "N/A" ]; then
  dd=$(awk -v a="$dur_a" -v v="$dur_v" 'BEGIN{d=a-v; if(d<0)d=-d; printf "%.2f", d}')
  le "$dd" 0.15 && ok "Audio y video alineados en duración" || warn "Audio y video difieren ${dd} s"
fi

# 7. Curva de energía (arco)
echo "  Curva short-term LUFS cada 2 s (busca: gancho → subida → quiebre → impacto → cola):"
curva=$(ffmpeg -nostats -i "$f" -vn -af "ebur128=metadata=1,ametadata=print:key=lavfi.r128.S" -f null - 2>&1 \
 | grep -E "pts_time|r128.S" | paste - - | sed -E 's/.*pts_time:([0-9.]+).*r128.S=(-?[0-9.]+).*/\1 \2/' \
 | awk '$1>=3 {t=int($1); if (t>=last+2){printf "%ds:%.0f ", t, $2; last=t}}')
echo "    $curva" | fold -w 110 -s | sed '2,$s/^/    /'
# Spread P10–P90 sin el último punto (el fade final no cuenta como arco)
rango=$(echo "$curva" | tr ' ' '\n' | awk -F: 'NF==2 && $2+0>-60{v[n++]=$2+0} END{n--; if(n<3){print 0; exit}; for(i=0;i<n;i++)for(j=i+1;j<n;j++)if(v[j]<v[i]){t=v[i];v[i]=v[j];v[j]=t}; printf "%.0f", v[int(n*0.9)]-v[int(n*0.1)]}')
if [ "${rango:-0}" -ge 4 ]; then ok "La curva se mueve ${rango} dB entre P10 y P90 (hay arco)"
else warn "La curva solo se mueve ${rango} dB entre P10 y P90: plana, ¿dónde está el quiebre?"; fi

echo "  ---"
if [ "$fallas" -gt 0 ]; then echo "RESULTADO: FALLA ($fallas fallas, $advert advertencias)"; exit 1
else echo "RESULTADO: APROBADO ($advert advertencias)"; exit 0; fi
