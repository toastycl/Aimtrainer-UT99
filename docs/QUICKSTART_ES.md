# Aimtrainer UT99 — prueba de desarrollo 0.4.0

Creado por **ToastyCL** para toda la comunidad. Esta entrega agrega las once armas clásicas, selección de entorno Local/IGPlus y latencia elegible dentro del menú. Sigue pendiente la aceptación manual en Windows/macOS y con tu mouse.

## 1. Instalar el paquete

Usa una **copia de prueba completa de UT99 469e**. Cierra el juego y extrae `UTAT-dev-0.4.0.zip` en la carpeta raíz de UnrealTournament, conservando las carpetas. Reemplaza:

- `System/UTAT.u` y `System/UTAT.int`.
- `System/UTATNetLab.u`.
- `Maps/DM-UTAT-Room.unr`.
- `tools/` y los archivos `Start-Aimtrainer.cmd`, `Start-Aimtrainer.sh` y `LEEME.md` de la raíz.

No borres User.ini ni UnrealTournament.ini. No necesitas compilar ni usar UnrealEd.

## 2. Dependencias de IGPlus

Para el modo IGPlus necesitas **Python 3.10 o superior** en tu PC y los paquetes oficiales de [IGPlus 11](https://github.com/utspect/InstaGibPlus/releases/tag/11):

- `InstaGibPlus_11.u` → `UnrealTournament/System/`.
- `InstaGibPlusAssets_v2.u` → `UnrealTournament/System/`.

Esos paquetes externos y los archivos originales del juego no están incluidos. No reemplaces los paquetes de un servidor en producción. El modo Local funciona directamente desde UT sin iniciar el helper y no necesita IGPlus.

## 3. Abrir y seleccionar el ping

En Windows, ejecuta **Start-Aimtrainer.cmd** en la raíz de tu copia de UT. Deja abierta esa ventana mientras juegas. Inicia el programa auxiliar y UT; el panel de entrenamiento se abre automáticamente.

En el panel:

1. **Environment:** elige **IGPlus / all classic weapons**.
2. **IGPlus added RTT / 0-300 ms:** escribe el valor que quieras, por ejemplo **85**. Se aceptan todos los enteros entre 0 y 300; no son presets.
3. Elige el arma, blancos estáticos o con strafe y duración.
4. Pulsa el único botón **Start training**. El panel espera que el servidor esté listo y entra a la sala.

El número es **latencia añadida de ida y vuelta**. 85 añade 42,5 ms por dirección. No obliga a que el scoreboard muestre exactamente 85. El HUD distingue lo solicitado del **Game ping**, el ping informado por UT. Puede fluctuar e incluir el suavizado propio del juego; no lo fuerzo al valor ingresado. 0 significa sin retardo adicional; no significa latencia física cero.

Para cambiar los ms entre rondas, vuelve al selector, escribe otro valor y pulsa Start. El helper inicia una sesión nueva y elimina el tráfico pendiente de la anterior. No aplica cambios de latencia a mitad de ronda.

Alternativa Linux: `bash Start-Aimtrainer.sh`. La prueba automática se hizo en Linux; la aceptación visual y de input en Windows/macOS aún requiere revisión. El lanzador no detecta todavía una instalación `.app` de macOS.

## 4. Jugar y ver los resultados

- Hay tres personajes de 100 HP, quietos o con movimiento lateral. Los puntos de inicio y respawn son aleatorios, separados del jugador.
- Puedes moverte, saltar y hacer dodge. El jugador está protegido del daño de práctica.
- Todas las armas tienen munición infinita; Impact Hammer no utiliza munición.
- Las rondas de 30/60/120 segundos terminan automáticamente. El reloj es del servidor en IGPlus. El menú pausa la ronda, con un breve tiempo de propagación de red.
- En práctica libre, abre **Mods → UT99 Aimtrainer** y pulsa **Finish round**.
- Al terminar, las estadísticas aparecen **sobre la sala**, sin abrir el menú.
- Suelta el disparo y presiona **un nuevo disparo primario** para volver al selector. Ese clic no debe disparar ni modificar el score.

Cerrar UT también cierra el servidor y el relay que inició el lanzador. No cierra procesos de servidores externos.

## 5. Armas y accuracy

Disponibles en Local e IGPlus: **Shock, Sniper, Minigun, Pulse, Rocket, Flak, Enforcer, Bio, Ripper, Impact Hammer y Redeemer**. Los secundarios no están bloqueados. Sniper secundario es zoom. El Translocator es una utilidad y no forma parte de este selector de armas de daño.

Accuracy = unidades emitidas que dañaron a un blanco / unidades emitidas × 100. Se cuentan trazas/balas, proyectiles o fragmentos según el disparo. Una unidad con splash cuenta una sola vez aunque dañe a varios blancos; los fragmentos derivados de una explosión conservan el token del proyectil padre. En un combo de Shock que daña blancos se acreditan los dos componentes: orb y traza detonadora.

**Pulse secundario tiene otra métrica:** porcentaje del tiempo de contacto del beam con un blanco, mostrado por separado. No lo compares con el porcentaje de proyectiles. Para comparar sensibilidad usa la misma arma y el mismo disparo por ronda, y repite varias veces: la dificultad cambia por los spawns aleatorios. El mod no mide DPI ni latencia física del mouse.

## 6. Prueba sugerida para mañana

1. Local: Sniper, estáticos, 30 segundos. Comprueba timer, respawns, munición y resultados.
2. IGPlus: misma selección, **0 ms**, luego **85 ms**, luego **143 ms** y **300 ms**. Comprueba que el HUD distinga retardo solicitado y ping informado por el juego.
3. Repite con blancos en movimiento. Cambia libremente a las demás armas, incluidos los secundarios.
4. Deja una ronda terminar mientras mantienes disparo: el resultado no debe saltarse. Suelta y vuelve a disparar para regresar al selector.
5. Repite con otra arma/duración/ms. Comprueba que se mantengan las selecciones y que los contadores empiecen en cero.
6. Prueba Finish round, cerrar el menú para seguir y cerrar completamente UT.

Anota versión del cliente, sistema operativo, arma/disparo, ms, ejercicio y pasos del problema. Si hay un error, conserva `System/UnrealTournament.log` (o `System64/UnrealTournament.log`) y `build/menu-server.log` antes de volver a iniciar. Revisa los logs antes de compartirlos: pueden contener información de tu instalación.

## Ayuda

- **Helper unavailable:** abre UT usando Start-Aimtrainer.cmd; no basta con abrir el `.exe` normal para IGPlus. Para Local sí puedes usar el `.exe` normal y Mods.
- **Missing System/…:** instala el archivo indicado en la copia de prueba.
- **Puerto ocupado:** cierra otra copia del lanzador. Se usan solo puertos locales UDP 17777, 18777 y 18778.
- Si el panel no aparece, abre **Mods → UT99 Aimtrainer**. `AimMenu` sigue disponible con el jugador del modo Local.
- About / Credits muestra ToastyCL, versión, fecha UTC y alcance del proyecto.

Se utiliza IGPlus 11 con su perfil normal de armas `WeaponSettingsOldNet`. Esto permite probar su jugador, movimiento y armas con tráfico real; aún no certifica equivalencia con la configuración exacta de tu servidor, sus hitboxes de jugadores humanos o ACE.
