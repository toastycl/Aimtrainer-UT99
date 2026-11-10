# Aimtrainer UT99 0.4.1 — instalar y jugar

Esta versión vuelve al entrenamiento local dentro de UT. **No requiere Python, IGPlus ni programas auxiliares.**

1. Cierra UT y extrae `UTAT-standalone-0.4.1.zip` en una copia de UT99 469e, conservando las carpetas.
2. Reemplaza `System/UTAT.u`, `System/UTAT.int` y `Maps/DM-UTAT-Room.unr`. No borres tus ini.
3. Abre el juego normalmente y entra a **Mods → UT99 Aimtrainer**.
4. Elige arma, blancos estáticos/en movimiento y duración. Pulsa **Start training**.
5. Al terminar aparecen las estadísticas sobre la sala. Suelta el disparo y presiona un nuevo disparo primario para volver al selector.

Hay once armas clásicas, con secundarios disponibles, munición infinita, tres blancos de 100 HP y spawns aleatorios separados. En práctica libre usa Finish round; abrir el menú pausa la ronda. `AimMenu`, `AimRestart`, `AimFinish` y `AimStop` siguen disponibles.

El accuracy cuenta trazas/balas, proyectiles o fragmentos según el disparo. El splash cuenta una vez por unidad; Pulse secundario muestra tiempo de contacto del beam aparte. Compara la misma arma y el mismo disparo, con varias rondas. El mod no detecta ni cambia DPI: usa tus ajustes normales del mouse y del cliente.

## Si probaste la 0.4.0

Cierra UT y cualquier lanzador anterior antes de reemplazar archivos. Usa el ejecutable normal de UT para esta versión. No uses Start-Aimtrainer.cmd ni instales componentes adicionales. Los antiguos UTATNetLab.u, tools y lanzadores no son necesarios; puedes conservarlos fuera de la copia de práctica si quieres guardar el experimento. Los ini de práctica de aquel lanzador no son necesarios para el arranque normal.

No hace falta desinstalar Python de tu equipo. Simplemente ya no se usa para jugar este mod.

## Prueba rápida

Sniper / estáticos / 30 segundos: comprueba el tiempo, los respawns, las estadísticas y el disparo para salir. Repite con movimiento y otras armas. About / Credits muestra ToastyCL y la versión.

La prueba física/visual en tu sistema sigue siendo necesaria. Si hay un error, indica cliente, OS, arma/disparo, ejercicio y pasos para reproducirlo. Conserva el log antes de reiniciar y revísalo antes de compartirlo.
