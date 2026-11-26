# 08 — Sincronía audiovisual: cuándo y a qué nivel entra cada sonido

El audio es el complemento perfecto cuando **cada evento visual importante tiene una respuesta sonora proporcional**, y los eventos menores no la tienen. Este documento define esa respuesta al frame.

Referencia de tiempo a 30 fps: 1 frame = 33 ms · 3 frames = 0.1 s · 15 frames = 0.5 s. (A 25 fps: 1 frame = 40 ms; a 60 fps: 17 ms.)

## 1. Tabla de entradas por efecto

Niveles en LUFS de corto plazo antes del master, salvo que se indique pico. Música de referencia: −16 sin voz, −29 con voz.

| Efecto | Cuándo empieza | Punto de sincronía | Duración | Nivel sin voz | Nivel con voz |
|---|---|---|---|---|---|
| **Whoosh de transición** | 6–10 frames antes del corte | Su pico en el frame del corte | = duración de la transición (0.3–0.6 s) | −20 a −18 | −26 a −24, o se mueve a una pausa |
| **Riser** | 2–4 s antes del reveal | Termina 1 frame antes del reveal | 2–4 s | Sube de −30 a −16 | No usar bajo la voz |
| **Impacto / golpe grave** | En el frame exacto del reveal | Frame 0 | 0.5–1.5 s de cola | Pico −3 a −1 dBFS | Solo si la voz calla en ese momento |
| **Silencio antes del impacto** | 3–15 frames antes | — | 0.1–0.5 s | Silencio o solo cola | — |
| **Clic de UI** | En el frame donde el botón cambia visualmente (±1 frame) | Frame del cambio | < 150 ms | −24 a −22 | −28 a −26 |
| **Pop / tick de texto** | En el frame en que aparece el texto | Frame de aparición | < 120 ms | −26 a −24 | −30 a −28 |
| **Reverse reverb** | 0.5–1 s antes | Termina en el inicio de la voz o del logo | 0.5–1 s | −22 a −18 | — (precede a la voz) |
| **Ambiente / foley de escena** | 6–12 frames antes del corte (J-cut) | Continúa hasta el corte siguiente | Lo que dura la escena | −30 a −26 | −34 a −30 |
| **Logo sonoro** | En el frame en que aparece el logo | Frame del logo | 1.2–1.8 s | −16 a −14 | Sin voz encima |
| **Glitch / stutter** | En el frame del glitch visual | Mismo frame | = glitch | −22 a −18 | Evitar |

## 2. Reglas de densidad

- **Promedio máximo: 1 efecto cada 1.5 s.** Más que eso se vuelve ruido de plantilla.
- **Nunca dos efectos de transición en menos de 0.5 s.**
- **Máximo 3 textos con sonido cada 15 s.** Solo los textos clave suenan; si todos suenan, ninguno destaca.
- **Un solo impacto por pieza** (dos en piezas de 60 s). Es la recompensa; repetirlo la devalúa.
- **Nunca tapar una sílaba de la voz.** Mover el efecto a una pausa o bajarlo 6 dB.

## 3. Traducir lo visual a sonido

La respuesta sonora debe **parecerse** al evento visual:

| Lo que se ve | Lo que debe sonar |
|---|---|
| Movimiento rápido | Whoosh corto y brillante |
| Movimiento lento y pesado | Whoosh largo y grave |
| Objeto grande o golpe | Contenido grave (sub + armónicos) |
| Objeto pequeño o detalle | Agudo, corto, nítido |
| Zoom in / acercamiento | Riser, el pitch sube, el filtro se abre |
| Zoom out / alejamiento | El pitch baja, el filtro se cierra, reverb |
| Colores brillantes o flash | Brillo espectral (agudos) |
| Oscuridad o pantalla negra | Grave, silencio o pedal |
| Cámara lenta | Música con pasa-bajos y reverb ("bajo el agua"); el ambiente se apaga |
| Glitch o error | Stutter digital, corte del audio |
| Pantalla de software | Clics de UI y teclado nítidos y cercanos |
| Personas o equipo | Voces reales, ambiente, risas |
| Logo o endcard | Logo sonoro; todo lo demás se retira |

## 4. Escalar la respuesta: la jerarquía

Cada evento visual tiene un peso. El sonido debe respetar esa jerarquía:

1. **Nivel 1, el mensaje** (reveal, cifra, logo): impacto o logo sonoro, precedido de silencio. Lo más fuerte de la pieza.
2. **Nivel 2, cambios de sección** (problema → solución): cambio de la música (apertura, entrada de capas) + un efecto.
3. **Nivel 3, cortes normales:** solo el corte en el beat, sin efecto.
4. **Nivel 4, detalles** (texto secundario, íconos): sin sonido, o un tick muy bajo.

Error típico: dar sonido de nivel 1 a eventos de nivel 3. Todo suena importante y nada lo es.

## 5. Proceso al frame

1. Exportar o mirar el video y anotar cada evento con su timecode y su nivel de jerarquía (1–4).
2. Ubicar la pista: su cambio fuerte sobre el evento de nivel 1 y los cortes sobre beats.
3. Agregar los efectos solo para los niveles 1 y 2 (y los clics de UI en demos).
4. Revisar a velocidad normal en el celular:
   - Si un efecto "se nota" como efecto, está muy fuerte o sobra.
   - Si un corte "se siente" torpe, revisar el desfase de frames.
5. Cuadro por cuadro en los hit points: que el pico del sonido caiga en el frame correcto.

Para posicionar efectos con ffmpeg (adelay en ms = frame / fps × 1000), ver `05-ffmpeg-recetas.md`.
