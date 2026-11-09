# Aimtrainer UT99 0.2.1 — sala de práctica

## Instalar el ZIP compilado

Cierra el juego y usa una copia de prueba de tu UT99 con 469e. Extrae el ZIP conservando las carpetas:

- `System/UTAT.u` → `UnrealTournament/System/`
- `System/UTAT.int` → `UnrealTournament/System/`
- `Maps/DM-UTAT-Room.unr` → `UnrealTournament/Maps/`

No necesitas Python ni UnrealEd para instalarlo. El ZIP de código fuente que descarga GitHub no contiene los binarios compilados.

## Entrar y entrenar

1. Abre **Mods → UT99 Aimtrainer → Enter training room**. Alternativa por consola: `open DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?NumBots=0`.
2. Dentro de la sala, abre **Mods → UT99 Aimtrainer**, o ejecuta `AimMenu`.
3. Elige **arma**, **blancos estáticos o con strafe** y **30/60/120 segundos o práctica libre**.
4. Pulsa **Start / Play again**. Empiezas desde el mismo punto frente a tres personajes de 100 HP que reaparecen al eliminarlos. Puedes moverte, saltar y hacer dodge.
5. Al acabar el tiempo se abre el panel de resultados. En práctica libre usa **Finish and show score**, o `AimFinish`.
6. Revisa accuracy, impactos/unidades disparadas y eliminaciones. Pulsa **Start / Play again** para repetir; puedes cambiar arma o ejercicio.

El mapa incluido es una habitación rectangular simple con suelo plano y texturas de cuadrícula propias. No tienes que buscar una zona en un mapa normal.

## Armas

- Shock: disparo primario.
- Sniper: disparo primario y zoom.
- Minigun: ambos disparos.
- Pulse: proyectiles primarios.
- Rocket: cohetes primarios, incluyendo carga múltiple.
- Flak: fragmentos primarios.

Otros secundarios y armas quedan pendientes. El accuracy cuenta trazas/balas para hitscan, proyectiles para Pulse/Rocket y fragmentos para Flak. Un proyectil con daño de área cuenta una sola vez aunque dañe a varios blancos. El porcentaje de Flak es de fragmentos, no de cartuchos: compara siempre la misma arma y modalidad.

## Ajustes y repetición

Usa tu configuración habitual. No necesitas perfiles. Ajusta DPI desde el mouse, sensibilidad/input desde el cliente y repite el ejercicio. El mod no cambia ni detecta DPI automáticamente.

`AimRestart` reinicia la ronda; `AimStop` cancela. `AimFinish` muestra el resultado; si terminas antes del tiempo elegido, verás el score pero esa ronda no entra a la comparación de rondas completas. En práctica libre puedes terminar cuando quieras.

La prueba visual/jugable del menú y del mouse en tu cliente sigue siendo necesaria. Consulta `docs/VALIDATION.md` para conocer las verificaciones exactas.

## Correcciones 0.2.1

Reemplaza **los tres archivos**, incluido el mapa, con UT cerrado. No hace falta borrar User.ini ni UnrealTournament.ini.

El jugador aparece en un punto lateral de espera y al iniciar pasa a su línea de tiro. Los blancos tienen su propio origen, a distancia. Los bots de DeathMatch se bloquean aunque tu configuración normal tenga bots habilitados. El jugador está protegido del daño de práctica y de telefrags.

La munición es infinita desde que recibes el arma; el HUD stock muestra 999. No depende de recargas ni del estado de la ronda.

El tiempo seleccionado cuenta segundos reales de juego activo, ajustados por la velocidad de juego. Abrir el menú pausa la práctica; al iniciar o repetir se reanuda explícitamente. Al terminar se abre el panel de resultados. Al cerrar el menú quedan las estadísticas en el HUD. `AimFinish` y el botón “Finish and show score” finalizan por el mismo método.
