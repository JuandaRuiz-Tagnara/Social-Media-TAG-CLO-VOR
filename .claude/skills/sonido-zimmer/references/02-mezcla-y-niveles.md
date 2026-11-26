# 02 — Mezcla y niveles: los números

## 1. Objetivos de entrega

| Parámetro | Objetivo | Tolerancia | Por qué |
|---|---|---|---|
| Loudness integrado | **−14 LUFS** | −15 a −13 | Práctica estándar para IG/TikTok/YouTube/FB; consistencia entre piezas |
| True peak | **≤ −1.0 dBTP** | nunca > −1.0 | La recodificación de la plataforma (AAC) genera picos extra y distorsión |
| LRA | **4–8 LU** | 3–10 | <3 = muro plano; >10 = partes inaudibles en celular |
| Sample rate | **48 kHz** | — | Estándar de video; 96 kHz no aporta y pesa |
| Códec | AAC-LC 320 kbps estéreo | ≥ 192 kbps | La plataforma recodifica; entregar con margen |
| Mono | Caída ≤ 4 dB al sumar L+R | — | Parlante del celular = mono |

Las plataformas no publican un objetivo oficial único. −14 LUFS / −1 dBTP es el consenso de la industria y el valor que usamos siempre, para que todas las piezas de la cuenta suenen parejas.

## 2. Niveles por elemento (short-term LUFS, antes del master)

| Elemento | Nivel | Nota |
|---|---|---|
| Voz en off / testimonio | −16 | Referencia de toda la mezcla |
| Música bajo voz | −28 a −32 | 12–16 dB por debajo de la voz |
| Música sin voz (intro, clímax) | −16 a −14 | Puede tomar el protagonismo |
| Ambiente real (evento, sala) | −30 a −26 | Da realismo, no compite |
| Whoosh / transición | −24 a −18 | Se siente, no se nota |
| Impacto en el momento clave | pico −3 a −1 dBFS | El elemento más fuerte de la pieza, una sola vez |
| Logo sonoro de cierre | −16 a −14 | Igual en todas las piezas de la marca |

En dB de fader: si la voz está a 0, la música va de −12 a −16 mientras hay voz y sube de +6 a +10 cuando la voz calla (con ducking).

## 3. Cadena de voz (en este orden)

1. **Pasa-altos 80 Hz** (voz masculina 70–80, femenina 90–100): elimina el retumbo y el ruido de manipulación.
2. **Reducción de ruido suave** (afftdn nf −25): más agresiva genera voz "robótica".
3. **EQ sustractiva:** −2 a −3 dB en 200–300 Hz (barro o caja) y −2 dB en 500 Hz si suena nasal.
4. **Compresor:** umbral −18 dB, ratio 3:1, ataque 5 ms, release 80 ms, 3–6 dB de reducción.
5. **EQ aditiva:** +2 a +3 dB en 3 kHz (presencia, inteligibilidad) y +1 a +2 dB shelf en 10 kHz (aire).
6. **De-esser:** controlar las "s" en 5–8 kHz. Imprescindible tras sumar agudos.
7. **Limitador** de seguridad a −3 dBFS.

Grabación: a 15–20 cm del micrófono, en un cuarto con ropa o cortinas (sin eco). Picos de grabación entre −12 y −6 dBFS. Si llega por WhatsApp, pedir el archivo original: el audio de nota de voz comprimido no se arregla.

## 4. Música bajo voz

- **Ducking por sidechain:** la voz controla un compresor sobre la música. Calibrado con voz a −16 LUFS: threshold 0.03, ratio 6:1, ataque 20 ms, release 350 ms → ~13 dB de reducción mientras hay voz, 0 dB en pausas. El release largo evita que la música "bombee" entre palabras.
- **Bolsillo de frecuencias:** −2 a −4 dB en 2–4 kHz de la música, solo cuando hay voz. La voz se entiende sin subirla.
- **Arreglo:** si la pista tiene voz cantada, no usarla bajo voz en off. Dos voces = ninguna se entiende.

## 5. Grave en celular
Los parlantes de celular no reproducen por debajo de ~150–200 Hz. Un bombo o pedal que solo existe en 40–60 Hz **desaparece**.
- Saturar levemente el grave (o duplicarlo una octava arriba) para generar armónicos en 100–300 Hz.
- Pasa-altos de la mezcla final en 25–30 Hz: el sub-grave inaudible solo consume margen de loudness.

## 6. Estéreo
- Voz e impacto al **centro**.
- Música y ambiente pueden ser anchos, pero hay que verificar mono: si al sumar L+R la música cae más de 4 dB, hay problemas de fase.
- No usar efectos de "ensanchamiento" extremo: en mono producen cancelaciones.

## 7. Master
1. Bus final: pasa-altos 25 Hz.
2. (Opcional) Glue: compresor suave 1.5:1, 1–2 dB de reducción.
3. Loudnorm en **dos pasadas** (medir y aplicar con los valores medidos, `linear=true`) a −14 LUFS / −1.5 dBTP de margen.
4. Exportar a 48 kHz y AAC 320k.
5. Ejecutar `scripts/qa_audio.sh`.

`loudnorm` en una sola pasada usa modo dinámico y aplana la mezcla: **siempre usar dos pasadas.**

## 8. Errores frecuentes y su síntoma

| Síntoma | Causa probable | Corrección |
|---|---|---|
| "Se escucha bajito comparado con otros reels" | Integrado < −16 LUFS | Master a −14 |
| "Suena raspado al subirlo a IG" | True peak > −1 dBTP | Limitador + loudnorm 2 pasadas |
| "La música tapa la voz" | Sin ducking o música > −26 bajo voz | Sidechain + bolsillo en 3 kHz |
| "Cansa, todo igual" | LRA < 3 | Quitar compresión, crear quiebre y arco |
| "La música bombea" | Release del ducking muy corto | Release 300–400 ms |
| "En el celular no hay grave" | Grave solo en sub | Saturación/armónicos |
| "El final se corta feo" | Pista cortada a mitad de compás | Editar en el beat, cola dentro del video |
| "Clic al inicio/final" | Corte sin fade | Fades de 5–10 ms en cada edición |
