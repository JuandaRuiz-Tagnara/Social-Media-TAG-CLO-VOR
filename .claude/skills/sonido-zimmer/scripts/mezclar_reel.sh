#!/usr/bin/env bash
# Mezcla + master de reels — estándar Sonido Zimmer
#
# Uso:
#   bash mezclar_reel.sh --video in.mp4 [--voz voz.wav] [--musica pista.wav] [--efectos sfx.wav]
#        [--musica-inicio 12.5] [--musica-db 0] [--fade-out 2] --salida final.mp4
#   bash mezclar_reel.sh --video viejo.mp4 --solo-master --salida corregido.mp4
#
# - Voz: HPF 80, denoise suave, EQ, compresión 3:1, de-esser → −16 LUFS
# - Música: HPF 30 → −16 LUFS; si hay voz: bolsillo −2.5 dB @3 kHz + ducking por sidechain (calibrado: ~13 dB con voz a −16 LUFS, 0 dB en pausas)
# - Efectos: pista ya posicionada (misma duración que el video), se suma tal cual
# - Master: HPF 25, ganancia a −14 LUFS + limitador (TP ≤ −1 dBTP), 48 kHz, AAC 320k
# - Ejecuta qa_audio.sh al final
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

video="" voz="" musica="" efectos="" salida="" solo_master=0
musica_ini=0 musica_db=0 fade_out=0
while [ $# -gt 0 ]; do
  case "$1" in
    --video) video="$2"; shift 2;; --voz) voz="$2"; shift 2;; --musica) musica="$2"; shift 2;;
    --efectos) efectos="$2"; shift 2;; --salida) salida="$2"; shift 2;;
    --musica-inicio) musica_ini="$2"; shift 2;; --musica-db) musica_db="$2"; shift 2;;
    --fade-out) fade_out="$2"; shift 2;; --solo-master) solo_master=1; shift;;
    *) echo "Argumento desconocido: $1"; exit 2;;
  esac
done
[ -f "$video" ] && [ -n "$salida" ] || { sed -n '4,8p' "$0"; exit 2; }
[ "$solo_master" = 1 ] || [ -n "$voz$musica$efectos" ] || { echo "Falta --voz, --musica, --efectos o --solo-master"; exit 2; }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$video")
FMT="aformat=sample_rates=48000:channel_layouts=stereo"
lufs() { ffmpeg -nostats -i "$1" -af loudnorm=print_format=json -f null - 2>&1 | grep '"input_i"' | tr -dc '0-9.\-'; }
# Normaliza un stem a un objetivo de LUFS con ganancia lineal (no aplana dinámica)
norm() { local g; g=$(awk -v t="$3" -v i="$(lufs "$1")" 'BEGIN{printf "%.2f", t-i}'); ffmpeg -v error -y -i "$1" -af "volume=${g}dB" "$2"; }

if [ "$solo_master" = 1 ]; then
  ffmpeg -v error -y -i "$video" -vn -af "$FMT" -t "$D" "$tmp/mix.wav"
else
  inputs=(); labels=()
  if [ -n "$voz" ]; then
    ffmpeg -v error -y -i "$voz" -af "highpass=f=80,afftdn=nf=-25,equalizer=f=250:t=q:w=1:g=-3,\
acompressor=threshold=-18dB:ratio=3:attack=5:release=80:makeup=3,equalizer=f=3000:t=q:w=1:g=2.5,\
equalizer=f=10000:t=h:w=0.7:g=1.5,deesser=i=0.4,alimiter=limit=0.7,$FMT,apad,atrim=0:$D" "$tmp/voz_p.wav"
    norm "$tmp/voz_p.wav" "$tmp/voz.wav" -16
  fi
  if [ -n "$musica" ]; then
    eq=""; [ -n "$voz" ] && eq=",equalizer=f=3000:t=q:w=1.2:g=-2.5"
    ffmpeg -v error -y -ss "$musica_ini" -i "$musica" -af "highpass=f=30${eq},$FMT,apad,atrim=0:$D,afade=t=in:d=0.01" "$tmp/mus_p.wav"
    norm "$tmp/mus_p.wav" "$tmp/mus.wav" "$(awk -v d="$musica_db" 'BEGIN{print -16+d}')"
  fi
  [ -n "$efectos" ] && ffmpeg -v error -y -i "$efectos" -af "$FMT,apad,atrim=0:$D" "$tmp/sfx.wav"

  fc=""; n=0; args=()
  for s in voz mus sfx; do [ -f "$tmp/$s.wav" ] && { args+=(-i "$tmp/$s.wav"); eval "idx_$s=$n"; n=$((n+1)); }; done
  parts=()
  if [ -f "$tmp/voz.wav" ] && [ -f "$tmp/mus.wav" ]; then
    fc="[${idx_voz}:a]asplit=2[v][key];[${idx_mus}:a][key]sidechaincompress=threshold=0.03:ratio=6:attack=20:release=350:makeup=1[m];"
    parts=("[v]" "[m]")
  else
    [ -f "$tmp/voz.wav" ] && parts+=("[${idx_voz}:a]")
    [ -f "$tmp/mus.wav" ] && parts+=("[${idx_mus}:a]")
  fi
  [ -f "$tmp/sfx.wav" ] && parts+=("[${idx_sfx}:a]")
  fc+="$(printf '%s' "${parts[@]}")amix=inputs=${#parts[@]}:normalize=0:duration=longest[out]"
  ffmpeg -v error -y "${args[@]}" -filter_complex "$fc" -map "[out]" "$tmp/mix.wav"
fi

# Master: HPF + ganancia lineal a −14 + limitador; 2 iteraciones para clavar el objetivo
fades="afade=t=in:d=0.005"
if awk -v f="$fade_out" 'BEGIN{exit !(f>0)}'; then fades+=",afade=t=out:st=$(awk -v d="$D" -v f="$fade_out" 'BEGIN{print d-f}'):d=$fade_out"
else fades+=",afade=t=out:st=$(awk -v d="$D" 'BEGIN{print d-0.01}'):d=0.01"; fi
ffmpeg -v error -y -i "$tmp/mix.wav" -af "highpass=f=25,$fades" "$tmp/pre.wav"
tp() { ffmpeg -nostats -i "$1" -vn -af loudnorm=print_format=json -f null - 2>&1 | grep '"input_tp"' | tr -dc '0-9.\-'; }
# Limitador con sobremuestreo 4x (aproxima true-peak) y verificación DESPUÉS de codificar en AAC,
# porque el encoder genera picos entre muestras. Reintenta bajando el techo hasta TP ≤ −1.0 dBTP.
lim=-2.0
for intento in 1 2 3 4; do
  src="$tmp/pre.wav"
  for it in 1 2; do
    g=$(awk -v i="$(lufs "$src")" 'BEGIN{printf "%.2f", -14-i}')
    ffmpeg -v error -y -i "$src" -af "volume=${g}dB,aresample=192000,alimiter=limit=${lim}dB:level=0:attack=1:release=60,aresample=48000" "$tmp/master$it.wav"
    src="$tmp/master$it.wav"
  done
  ffmpeg -v error -y -i "$video" -i "$src" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 320k -ar 48000 -t "$D" -movflags +faststart "$salida"
  t=$(tp "$salida")
  awk -v t="$t" 'BEGIN{exit !(t<=-1.0)}' && break
  lim=$(awk -v l="$lim" -v t="$t" 'BEGIN{printf "%.2f", l-(t+1.0)-0.3}')
  echo "  True peak ${t} dBTP tras AAC → reintento con techo ${lim} dB"
done
echo "Exportado: $salida (techo del limitador ${lim} dB)"
bash "$DIR/qa_audio.sh" "$salida"
