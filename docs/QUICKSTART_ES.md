# Aimtrainer UT99 0.3.1 — sala de práctica

## Instalar

Cierra UT y extrae el ZIP compilado en una copia de prueba de UT99 469e. Reemplaza los tres archivos, incluido el mapa:

- `System/UTAT.u` → `UnrealTournament/System/`
- `System/UTAT.int` → `UnrealTournament/System/`
- `Maps/DM-UTAT-Room.unr` → `UnrealTournament/Maps/`

No necesitas Python ni UnrealEd. No borres User.ini ni UnrealTournament.ini. GitHub “Download ZIP” descarga fuentes; usa el ZIP compilado de `downloads/`.

## Entrenar

1. Abre **Mods → UT99 Aimtrainer**.
2. Selecciona arma, blancos estáticos o con strafe y 30/60/120 segundos o práctica libre.
3. Pulsa **Start training**. Ese único botón entra a la sala e inicia con tu selección; dentro de la sala sirve para repetir.
4. Dispara a tres personajes de 100 HP. Tienes munición infinita (HUD: 999). Puedes moverte, saltar y hacer dodge.
5. Al cumplirse el tiempo aparecen los resultados **sobre la sala**, sin abrir el menú. En práctica libre abre `AimMenu` y pulsa **Finish round**, o ejecuta `AimFinish`.
6. Revisa accuracy, impactos/unidades emitidas, eliminaciones y tiempo. **Presiona un nuevo disparo primario** para volver al selector. Ese clic no dispara el arma ni modifica el score. Un disparo que quedó mantenido al finalizar no debe saltarse el resultado.

Alternativa por consola: `open DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?NumBots=0`, luego `AimMenu`.

## Apariciones y tiempo

La sala es rectangular, plana y usa texturas de cuadrícula propias. El jugador inicia cada ronda en un punto aleatorio de su zona. Los blancos aparecen y reaparecen aleatoriamente en otra zona: se evita repetir el último punto y se comprueba distancia al jugador, separación entre blancos y línea de visión al aparecer. El jugador está protegido del daño y de telefrags; no hay bots de combate heredados de DeathMatch.

Los blancos con strafe se desplazan lateralmente cerca de su punto aleatorio. No son oponentes con IA completa. El tiempo cuenta segundos reales de juego activo; abrir el menú pausa la ronda y Start la reanuda. `AimRestart` cancela y reinicia; `AimStop` cancela y muestra contadores. Terminar anticipadamente una ronda con tiempo no la incorpora a comparaciones de rondas completas.

Las posiciones aleatorias hacen variar la dificultad: compara varias rondas con la misma arma y ejercicio. El registro guarda una semilla de posiciones; todavía no existe un control para repetir esa semilla desde el menú.

## Armas y accuracy

- Shock: primario.
- Sniper: primario y zoom.
- Minigun: ambos disparos.
- Pulse: proyectiles primarios.
- Rocket: cohetes primarios, incluyendo carga múltiple.
- Flak: fragmentos primarios.

Otros secundarios y armas quedan pendientes. Accuracy = unidades emitidas que dañaron a un blanco / unidades emitidas × 100. Una unidad es una traza/bala, un proyectil Pulse/Rocket o un fragmento Flak. El splash cuenta una sola vez por proyectil, aunque dañe varios blancos. Compara siempre la misma arma y modalidad; el accuracy Flak es por fragmentos, no por cartuchos.

## Sensibilidad, input e IGPlus

Usa tus ajustes habituales. Cambia DPI en el mouse y sensibilidad/input en el cliente, luego repite. El mod no detecta ni cambia DPI automáticamente. No exige perfiles.

Esta sala usa entrenamiento local. El laboratorio **IGPlus + latencia** es un paquete experimental separado para probar cliente y servidor reales, con Shock/Sniper y retardo UDP controlado; aún no tiene selector ni rondas de entrenamiento integradas. Consulta `docs/NETWORK_LAB.md`. Instalar este ZIP no activa IGPlus ni cambia servidores.

Verificaciones y límites: `docs/VALIDATION.md`. Sigue pendiente tu prueba visual/jugable con el mouse y sistema operativo habituales.

## About / Créditos

En **Mods → UT99 Aimtrainer**, pulsa **About / Credits**. Muestra ToastyCL, la versión 0.3.1, la fecha 2026-11-09 (UTC), las funciones del entrenador y sus límites. **Back to training setup** regresa sin perder el arma o la duración seleccionadas.

## Elegir los ms del laboratorio

Todavía no se eligen desde el menú del juego. En el laboratorio de desarrollo, el argumento `--rtt-ms` añade retardo al recorrido de ida y vuelta. `100` añade 50 ms por dirección; `150`, 75 ms por dirección. No modifica el entrenamiento local.

Con el repositorio y las dependencias del laboratorio preparados según `docs/NETWORK_LAB.md`, en Windows puedes usar:

```text
py scripts/net_smoke.py --ut-root "C:\Games\UnrealTournament" --weapon Shock --rtt-ms 100
py scripts/net_smoke.py --ut-root "C:\Games\UnrealTournament" --weapon Sniper --rtt-ms 150
```

La prueba dispara automáticamente y registra la estimación RTT y el impacto confirmado en servidor. Aún no es una ronda jugable con estadísticas de accuracy en red. Para entrenamiento normal instala únicamente el ZIP principal.

El nuevo avance WIP agrega un lanzador externo interactivo para escribir cualquier valor entero de ms y abrir un sandbox manual con IGPlus. Aún no agrega ese selector al menú de UT ni calcula accuracy en red. Instrucciones y tareas para colaboradores: `docs/WIP_SELECTABLE_PING.md`.
