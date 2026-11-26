# 03 — Transiciones, efectos y cierres

Regla madre: **cada sonido justifica un corte o un mensaje.** Un efecto sin propósito es ruido.

## 1. Transiciones

| Recurso | Cuándo | Timing | Nivel |
|---|---|---|---|
| **Corte en el beat** | Siempre, base de todo | Corte de imagen en el primer tiempo o en un golpe | — |
| **J-cut** | Cambio de escena o de tema | El audio nuevo entra 6–12 frames antes del corte | El del audio nuevo |
| **L-cut** | Dar peso a una frase | El audio anterior sigue 6–12 frames tras el corte | Igual, con fade corto |
| **Whoosh** | Movimiento de cámara o texto que entra | Pico del whoosh = frame del corte | −24 a −18 LUFS |
| **Riser** | Antes de un reveal (logo, producto, cifra) | 1.5–4 s y **corte seco** en el frame del reveal | Sube de −30 a −16 |
| **Reverse reverb / reverse cymbal** | Entrada de voz o de logo | Termina exactamente donde empieza la voz | −22 a −18 |
| **Filtro que abre** | Pasar de "problema" a "solución" | Pasa-bajos de 300 Hz a abierto en 1–2 s | Igual al de la música |
| **Corte a silencio** | Antes del mensaje clave (el quiebre Zimmer) | 0.3–0.8 s | Silencio digital o solo una cola |
| **Tape stop / pitch down** | Interrupción, "esto se acabó" (caos operativo) | 0.3–0.6 s | Igual al de la música |

Errores: un whoosh en cada corte (se vuelve muletilla); risers que no terminan en nada; transiciones que llegan 2–3 frames tarde (se siente amateur aunque no se sepa explicar).

## 2. Efectos (SFX)

- **Impacto / hit grave:** uno por pieza, en el momento clave. Precedido de silencio o filtro.
- **UI sounds (clics, notificaciones, teclado):** para demos de Clovai, sincronizados con cada interacción en pantalla. Cortos (< 150 ms), nivel −26 a −22.
- **Foley y ambiente real:** sala, evento, aplausos, voces de fondo. Da verdad; entra bajo (−30 a −26).
- **Texto animado:** solo los textos importantes llevan sonido (un "tick" sutil). Si todos suenan, ninguno destaca.

Procesar todo efecto de biblioteca: cambio de pitch (±2–5 semitonos), filtro y reverb de la marca. Así no suena igual al reel de la competencia.

## 3. Arranques (los primeros 0.5 s)

El scroll se decide en el primer segundo:
- **Nada de fade-in** en la música (excepto 5–10 ms anticlic).
- Abrir con: impacto + imagen, voz en seco con la frase gancho, o sonido real reconocible (alarma, teléfono, fila de pacientes).
- Si la pista tiene intro lenta, **cortarla**: entrar en el compás donde ya hay pulso.

## 4. Cierres

| Cierre | Uso | Cómo |
|---|---|---|
| **Final en el beat + cola** | El más versátil | Último golpe sobre el logo; reverb de 1–2 s que termina antes del último frame |
| **Logo sonoro** | Toda pieza de marca | 1–2 s, mismas notas siempre, sobre el endcard |
| **Silencio + frase** | Testimonios, mensajes fuertes | La música se corta y queda la voz sola diciendo la última frase |
| **Fade out** | Solo en piezas largas (> 60 s) o en loops de stand | 1.5–3 s, nunca más largo |
| **Loop perfecto** | Reels que se repiten | Que el final empalme con el arranque (mismo tempo y tonalidad); el usuario no nota el reinicio y aumenta la retención |

Prohibido: cortar la canción a mitad de compás, el fade de 5 s que se come el endcard, y el silencio de 1 s o más tras el logo.

## 5. Sincronía con la imagen (hit points)
1. Marcar en el timeline: arranque, cada corte, entrada de cada texto clave, el reveal y el endcard.
2. Ajustar la **música** para que su clímax caiga en el reveal (cortar o repetir compases).
3. Poner efectos solo en los hit points marcados.
4. Revisar a velocidad normal: si hay que pensar para notar la sincronía, está bien; si "se ve" el efecto, está muy fuerte.
