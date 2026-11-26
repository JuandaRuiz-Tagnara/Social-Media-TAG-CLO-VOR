# 05 — Recetas ffmpeg

Todas probadas con ffmpeg 6+. Reemplazar nombres de archivo.

## Medir
```bash
# Loudness integrado, true peak y LRA
ffmpeg -nostats -i in.mp4 -vn -af loudnorm=print_format=json -f null - 2>&1 | tail -12

# Curva de loudness short-term (para ver el arco)
ffmpeg -nostats -i in.mp4 -vn -af "ebur128=metadata=1,ametadata=print:key=lavfi.r128.S" -f null - 2>&1 | grep r128.S

# Info del stream de audio
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate,channels,bit_rate -of default=nw=1 in.mp4
```

## Cortar y editar pista
```bash
# Recortar música desde 12.5 s, 30 s de largo, con fades anticlic
ffmpeg -ss 12.5 -t 30 -i pista.wav -af "afade=t=in:d=0.01,afade=t=out:st=29.99:d=0.01" pista_30s.wav

# Fade out final de 2 s terminando a los 30 s
ffmpeg -i pista_30s.wav -af "afade=t=out:st=28:d=2" pista_fade.wav

# Calcular duración de un compás: 60/BPM*4 (4/4). A 120 BPM = 2.0 s
```

## Voz
```bash
ffmpeg -i voz_raw.wav -af "highpass=f=80,afftdn=nf=-25,equalizer=f=250:t=q:w=1:g=-3,\
acompressor=threshold=-18dB:ratio=3:attack=5:release=80:makeup=3,\
equalizer=f=3000:t=q:w=1:g=2.5,equalizer=f=10000:t=h:w=0.7:g=1.5,deesser=i=0.4,\
alimiter=limit=0.7" -ar 48000 voz_proc.wav
```

## Ducking (música baja cuando habla la voz)
```bash
ffmpeg -i musica.wav -i voz_proc.wav -filter_complex \
"[1:a]asplit=2[v][key];[0:a][key]sidechaincompress=threshold=0.03:ratio=6:attack=20:release=350[m];\
[m][v]amix=inputs=2:normalize=0[out]" -map "[out]" mezcla.wav
```

## Efectos posicionados
```bash
# Whoosh en 4.2 s y impacto en 9.5 s (adelay en ms)
ffmpeg -i whoosh.wav -i impacto.wav -filter_complex \
"[0:a]adelay=4200|4200,volume=-6dB[a];[1:a]adelay=9500|9500[b];[a][b]amix=inputs=2:normalize=0" efectos.wav
```

## Riser casero (ruido filtrado que sube, 3 s)
```bash
ffmpeg -f lavfi -i "anoisesrc=d=3:c=pink:a=0.3" -af "highpass=f=400,afade=t=in:d=3:curve=exp,volume=-6dB" riser.wav
```

## Reverse reverb (entrada de voz o logo)
```bash
ffmpeg -i palabra.wav -af "areverse,aecho=0.8:0.9:60|120|200:0.5|0.35|0.2,areverse" reverse_verb.wav
```

## Master en dos pasadas a −14 LUFS / −1.5 dBTP
```bash
# Pasada 1: medir
ffmpeg -nostats -i mezcla.wav -af loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json -f null - 2>&1 | tail -12
# Pasada 2: aplicar con los valores medidos (reemplazar)
ffmpeg -i mezcla.wav -af "loudnorm=I=-14:TP=-1.5:LRA=11:measured_I=X:measured_TP=X:measured_LRA=X:measured_thresh=X:offset=X:linear=true" -ar 48000 master.wav
```

## Unir con el video sin recodificar la imagen
```bash
ffmpeg -i video.mp4 -i master.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 320k -ar 48000 -shortest final.mp4
```

## Corregir un video ya exportado (solo master)
```bash
bash scripts/mezclar_reel.sh --video viejo.mp4 --solo-master --salida corregido.mp4
```
