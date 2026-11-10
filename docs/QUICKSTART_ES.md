# Aimtrainer UT99 0.5.0 — instalar y jugar

Esta versión vuelve al entrenamiento local dentro de UT. **No requiere Python, IGPlus ni programas auxiliares.**

1. Cierra UT y extrae `UTAT-standalone-0.5.0.zip` en una copia de UT99 469e, conservando las carpetas.
2. Reemplaza `System/UTAT.u`, `System/UTAT.int` y `Maps/DM-UTAT-Room.unr`. No borres tus ini.
3. Abre el juego normalmente y entra a **Mods → UT99 Aimtrainer**.
4. Elige arma, tipo de blanco, distancia, tamaño y duración. Pulsa **Start training**.
5. Al terminar aparecen las estadísticas sobre la sala. Suelta el disparo y presiona un nuevo disparo primario para volver al selector.

Hay once armas clásicas, con secundarios disponibles, munición infinita, tres blancos de 100 HP y spawns aleatorios separados. En práctica libre usa Finish round; abrir el menú pausa la ronda. `AimMenu`, `AimRestart`, `AimFinish` y `AimStop` siguen disponibles.

El accuracy cuenta trazas/balas, proyectiles o fragmentos según el disparo. El splash cuenta una vez por unidad; Pulse secundario muestra tiempo de contacto del beam aparte. Compara la misma arma y el mismo disparo, con varias rondas. El mod no detecta ni cambia DPI: usa tus ajustes normales del mouse y del cliente.

## Nuevas opciones

- **Static:** blancos quietos.
- **Lateral strafe:** movimiento lateral.
- **Evasive / jumps:** cambios de dirección/velocidad y saltos y aceleraciones tipo dodge simulados.
- **Random aerial:** posiciones y trayectorias aleatorias en el aire.
- **Distance:** Mixed, Close, Medium o Far. Son bandas horizontales desde tu posición inicial, no metros ni una distancia fija mientras te mueves.
- **Target size:** Normal, Small (60%) o Large (140%). Cambian el modelo y su cilindro de impacto.
- **Round history:** últimas diez rondas, persistentes entre partidas, tres por página. Incluye sensi, arma, ejercicio, distancia, tamaño, disparo primario/secundario/mixto, accuracy, beam, eliminaciones y tiempo. Las rondas terminadas antes del tiempo o canceladas se marcan partial.

Los aéreos son dummies flotantes para entrenar puntería. Los saltos evasivos son trayectorias de práctica; no replican la física exacta de jugadores humanos. No hay ping ni netcode simulado.

Para probar: Sniper / Random aerial / Medium / Normal / 30 segundos. Después repite con Small, luego con Evasive / jumps. Al terminar, vuelve al selector con un disparo nuevo y abre Round history. Compara varias rondas con condiciones iguales; los puntos de aparición siguen siendo aleatorios.

## Si probaste una versión anterior

Desde 0.4.1 solo reemplaza los tres archivos del mod/mapa, sin borrar tus ini. Tus perfiles se conservan; los controles nuevos comienzan en distancia mixta y tamaño normal.

## Si probaste la 0.4.0

Cierra UT y cualquier lanzador anterior antes de reemplazar archivos. Usa el ejecutable normal de UT para esta versión. No uses Start-Aimtrainer.cmd ni instales componentes adicionales. Los antiguos UTATNetLab.u, tools y lanzadores no son necesarios; puedes conservarlos fuera de la copia de práctica si quieres guardar el experimento. Los ini de práctica de aquel lanzador no son necesarios para el arranque normal.

No hace falta desinstalar Python de tu equipo. Simplemente ya no se usa para jugar este mod.

## Prueba rápida

Sniper / estáticos / 30 segundos: comprueba el tiempo, los respawns, las estadísticas y el disparo para salir. Repite con movimiento y otras armas. About / Credits muestra ToastyCL y la versión.

La prueba física/visual en tu sistema sigue siendo necesaria. Si hay un error, indica cliente, OS, arma/disparo, ejercicio y pasos para reproducirlo. Conserva el log antes de reiniciar y revísalo antes de compartirlo.
