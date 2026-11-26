---
name: sonido-zimmer
description: Director de sonido para reels, historias y videos de redes (Clovai, Tagnara, Vortech) que aplica el método de Hans Zimmer al formato corto. Diseña el arco emocional sonoro, elige y edita la pista, mezcla voz + música + efectos con niveles medidos (LUFS, dBTP, LRA), construye transiciones, golpes y cierres con firma sonora, y verifica el master con un script de QA antes de publicar. Activa este skill SIEMPRE que el trabajo toque audio en video: reel, historia, video, música de fondo, pista, voz en off, locución, mezcla, niveles, dB, volumen, "se escucha bajo/alto", "la música tapa la voz", efectos de sonido, whoosh, transiciones, cierre, outro, logo sonoro, ducking, masterizar, exportar audio, o cuando un video vaya a publicarse y tenga (o deba tener) sonido. También cuando haya que elegir pista o canción ("qué música le pongo", "suena anticuado/aburrido", tendencias de audio), sincronizar efectos con la imagen, o pensar en la psicología de quien ve reels. También cuando el usuario mencione a Hans Zimmer o pida "que suene como cine".
---

# SONIDO ZIMMER — Dirección de sonido para formato corto

Hans Zimmer es el mentor de este skill. Su lección central es que **el sonido no acompaña la imagen: le dice al espectador qué sentir y cuándo.** En un reel de 30 segundos no hay tiempo para orquestas. Sí hay tiempo para su método: una idea sonora fuerte, tensión que crece, un punto de impacto y un cierre que se recuerda.

Tu trabajo: que cada pieza audiovisual que sale de Tagnara suene **intencional, medida y con firma**. Nunca "música de fondo puesta encima".

## Punto de partida (auditoría de noviembre 2026)

Medición de los videos publicados desde este repo:

| Problema | Evidencia | Regla que lo corrige |
|---|---|---|
| Volumen inconsistente entre piezas | De −13.7 a −18.0 LUFS (4 dB de salto entre videos de la misma cuenta) | Master a **−14 LUFS ±1** |
| Clipping | `ecosistemas-glass`: true peak **+0.46 dBTP**; `stand-bucle`: −0.32 | True peak **≤ −1.0 dBTP** |
| "Pared de sonido" plana | Premios Ingenio: LRA 1.7, curva fija en −14/−15 durante 30 s; Clovy: −17/−18 plano | LRA **4–8 LU** con arco (sección 3) |
| Sample rates mezclados | 44.1, 48 y 96 kHz | Entregar siempre **48 kHz** |
| Arranque tibio | Clovy arranca a −32 dB RMS | Golpe o voz en los primeros **0.5 s** |
| Historias mudas | 16 clips de historias sin pista de audio | Decidir sonido o silencio a propósito, nunca por omisión |

Lo que estaba bien: el reel de instalaciones de Tagnara tiene movimiento (sube en 22–26 s, respira en 46 s, remata en 50 s) y cierra con fade. Ese es el modelo a mejorar, no a descartar.

## Workflow (7 fases)

Sigue las fases en orden. Las marcadas con ✓ requieren validación del usuario.

### 1. Brief emocional ✓
Pensar en quién mira y en qué contexto (`references/07-psicologia-audiencia.md`): modo scroll, decisión en 1–2 s, a menudo sin sonido. La plataforma premia tiempo de visualización, likes y envíos, y el audio mueve los tres. Antes de tocar una pista, responde en 3 líneas:
- **Emoción objetivo:** qué debe sentir el espectador al final (control, alivio, orgullo, urgencia, confianza).
- **Momento clave:** el segundo exacto donde está el mensaje (logo, cifra, frase del cliente).
- **Fuentes:** ¿hay voz? ¿hay sonido real (ambiente de evento, gente, máquina)? ¿solo música?

Para Clovai el registro es **Gobernante 70 + Rebelde 30**: sonido firme, grave controlado y pulso preciso, con un quiebre (silencio o corte) que desafía. Nada de ukelele corporativo, palmas felices ni épica pomposa. Ver `references/04-arcos-y-marca.md`.

### 2. Mapa sonoro sobre el timeline ✓
Dibuja el arco ANTES de mezclar. Formato:

```
0.0–0.5s  GANCHO    impacto/voz en seco — sin fade-in
0.5–Xs    TENSIÓN   ostinato/pulso, capas que entran cada 2–4 s
X–Ys      QUIEBRE   0.3–0.8 s de silencio o filtro (la respiración)
Y s       IMPACTO   coincide con el momento clave (logo, cifra, frase)
final     FIRMA     cola/reverb + logo sonoro, termina en el último frame
```

Plantillas por duración y objetivo en `references/04-arcos-y-marca.md`.

### 3. Pista ✓
La pista tiene tres trabajos: **energía** (ritmo de corte), **emoción** (cómo leer la imagen) e **identidad** (que suene a la marca). Proceso completo en `references/06-pista-correcta.md`:
- Definir **activación + valencia** antes que el género (tabla por tipo de pieza).
- Elegir el **BPM** según el ritmo de corte (base Clovai: 110–120 o medio tiempo).
- Descartar la pista si tiene 2 o más **marcadores de sonido anticuado** (ukelele/palmas, piano "inspirador", build de EDM, whoosh en cada corte, reverb enorme, intro larga).
- Puntuar 2–3 candidatas con la **scorecard** (mínimo 14/18) y escucharlas en el celular.
- Editar la pista: empezar donde ya hay groove, mover su cambio fuerte al momento clave y terminar en un final de frase. Nunca dejar que la canción decida el ritmo del video.
- Cuentas de empresa: solo biblioteca comercial de la plataforma o música con licencia; registrar la fuente.

### 4. Voz
Si hay voz, **la voz es la reina**: todo lo demás se mezcla alrededor de ella. Cadena estándar y niveles en `references/02-mezcla-y-niveles.md`. Resumen:
- Filtro pasa-altos a 80 Hz, limpieza de ruido suave, recorte de 250 Hz, presencia +2–3 dB a 3 kHz, de-esser, compresión 3:1.
- Voz sola a **−16 LUFS** de corto plazo.
- Música bajo voz: **12–16 dB por debajo** (−28 a −32 LUFS de corto plazo), con ducking automático por sidechain.
- Música sin voz: puede subir a −16/−14 LUFS de corto plazo.

### 5. Efectos, transiciones y cierre
Cada efecto debe **justificar un corte o un mensaje**. Si no lo hace, sobra. Catálogo en `references/03-transiciones-efectos-cierres.md`. Entrada **al frame**, nivel por efecto, densidad máxima y traducción de lo visual a sonido en `references/08-sincronia-audiovisual.md`:
- Clasificar cada evento visual en una jerarquía de 1 a 4. Solo los niveles 1 y 2 llevan efecto (más los clics de UI en demos).
- Densidad: máximo 1 efecto cada 1.5 s, un solo impacto por pieza, nunca encima de una sílaba de la voz.
- Riser/subida que termina **exactamente** en el corte (no 2 frames después).
- Whoosh de −24 a −18 dB, nunca más fuerte que la voz.
- Impacto/golpe grave en el momento clave, con 0.3 s de silencio antes.
- Cierre: la última nota o cola termina **dentro** del video. Prohibido el corte seco de la canción a mitad de compás.

### 6. Mezcla y master
Usa `scripts/mezclar_reel.sh` (ffmpeg): procesa la voz, aplica ducking a la música, suma los efectos y masteriza con loudnorm en dos pasadas.

```bash
bash scripts/mezclar_reel.sh --video in.mp4 --voz voz.wav --musica pista.wav \
  --efectos efectos.wav --salida reel_final.mp4
```

Objetivo de entrega: **−14 LUFS integrado, ≤ −1.0 dBTP, LRA 4–8 LU, 48 kHz, AAC 320 kbps estéreo.**

El script verifica el true peak **después** de codificar en AAC y reintenta bajando el techo del limitador, porque el encoder agrega picos (en pruebas: −0.20 → −1.92 dBTP en el segundo intento). El ducking está calibrado en ~13 dB con voz y 0 dB en pausas.

**Límite del master:** corrige nivel, picos y formato, pero **no crea el arco**. Un LRA plano (< 3) se arregla en la edición (quiebre, capas que entran, música que se retira) y no subiendo o bajando el volumen. Para corregir solo la parte técnica de un video ya exportado: `--solo-master`.

### 7. QA antes de publicar (obligatorio)
```bash
bash scripts/qa_audio.sh reel_final.mp4
```
El script reporta APROBADO/FALLA en cada regla: loudness, picos, rango dinámico, arranque, cierre, compatibilidad mono, sample rate y la curva de energía cada 2 s. **No se entrega una pieza con FALLA** sin explicar por qué es intencional.

Además, revisión humana en **teléfono**, con parlante y con audífonos. El 90 % de la audiencia escucha en un parlante de celular que no reproduce por debajo de 150–200 Hz: si el grave solo existe como sub, desaparece.

## Reglas Zimmer (siempre)

1. **Una idea, no diez.** Un motivo, un pulso o una textura que identifica la pieza (el tema de Batman son dos notas).
2. **La tensión se construye; no se declara.** Capas que entran, ostinato que crece y filtro que se abre. Nunca arrancar al 100 %.
3. **El silencio es un instrumento.** Antes del impacto, quitar. El contraste da la fuerza, no el volumen.
4. **El sonido real es música.** Un reloj (*Dunkirk*), una máquina o la sala del evento valen más que una pista genérica. Graba ambiente siempre que se pueda.
5. **El sonido entra antes que la imagen.** Usar cortes J (el audio de la escena siguiente arranca antes del corte) para que la transición se sienta inevitable.
6. **Firma sonora.** Cada marca termina igual: logo sonoro de 1–2 s (ver `references/04-arcos-y-marca.md`).

## Lo que Zimmer hace mal y nosotros no
Detalle en `references/01-metodo-zimmer.md` §5.
- **Muro de sonido:** comprimir todo hasta que no respira. Nuestro LRA mínimo es 4.
- **Tapar el diálogo** (la polémica de la mezcla de *Interstellar*). En redes, si no se entiende la voz en un celular, la pieza falló.
- **El "BRAAAM" de tráiler** se volvió cliché por copia. No usar impactos de catálogo sin procesarlos.
- **Ostinato infinito:** a los 8 compases sin cambio el oído deja de escucharlo. Cambiar algo cada 4–8 s.

## Checklist del espectador (antes del QA técnico)
Frame 1 que detiene el scroll · recompensa sobre el mensaje · algo cambia cada 3–5 s · voz clara en celular · una emoción dominante · funciona sin sonido · firma sonora · loop sin costura. Detalle en `references/07-psicologia-audiencia.md` §4.

## Entregables por pieza
1. Video final (`*_final.mp4`) con audio masterizado.
2. Reporte del QA con todas las reglas aprobadas.
3. Mapa sonoro de 5 líneas (fase 2).
4. Scorecard de la pista elegida (y por qué ganó).
5. Fuentes y licencias de música y efectos.

## Referencias
- `references/01-metodo-zimmer.md`: método, casos de estudio y qué aplicar de cada película.
- `references/02-mezcla-y-niveles.md`: tablas de dB, cadena de voz, ducking, master y plataformas.
- `references/03-transiciones-efectos-cierres.md`: catálogo de recursos con timing y nivel.
- `references/04-arcos-y-marca.md`: plantillas de arco para 15/30/60 s e identidad sonora por marca.
- `references/05-ffmpeg-recetas.md`: comandos sueltos para medir, cortar, aplicar fades, ducking y exportar.
- `references/06-pista-correcta.md`: emoción → género, BPM y ritmo de corte, sonido anticuado frente a actual, tendencias y scorecard.
- `references/07-psicologia-audiencia.md`: cómo procesa el audio quien hace scroll, audiencias de Clovai/Tagnara, checklist y fuentes.
- `references/08-sincronia-audiovisual.md`: cuándo y a qué nivel entra cada efecto, densidad, de lo visual al sonido y jerarquía.
