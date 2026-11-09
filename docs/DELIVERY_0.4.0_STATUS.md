# Estado de entrega 0.4.0 — 2026-11-09

**Publicación bloqueada.** La implementación y las pruebas descritas abajo se realizaron en el entorno de trabajo, pero ese entorno quedó no disponible antes del push final. Los archivos nuevos de código y el ZIP 0.4.0 todavía no están publicados en este repositorio. El último paquete descargable del entrenador sigue siendo 0.3.1, más el laboratorio WIP anterior.

Este documento conserva el avance y los pasos pendientes. No anuncia una versión lista para instalar ni asigna trabajo a un colaborador concreto.

## Implementado y probado en el entorno local

- Selector dentro de UT: Local / IGPlus, entero libre entre 0 y 300 ms, arma, ejercicio y duración.
- Once armas clásicas en ambos entornos: Shock, Sniper, Minigun, Pulse, Rocket, Flak, Enforcer, Bio, Ripper, Impact Hammer y Redeemer.
- Secundarios disponibles; Sniper secundario es zoom y Pulse beam tiene métrica de contacto temporal separada.
- Helper privado de localhost con petición validada, READY/ERROR, timeout y cancelación.
- Jugador de UTPure y adaptadores derivados de las armas/proyectiles reales de IGPlus 11.
- Rondas de servidor, pausa/reanudación del nivel, munición realmente infinita en cliente/servidor y blancos estáticos/móviles con spawns aleatorios.
- Contadores de unidades, impactos, daño y eliminaciones; deduplicación de splash y componentes de combo.
- Resultados sobre la sala; limpieza del disparo mantenido y un nuevo disparo primario para regresar al selector.
- Selección conservada al volver; About con ToastyCL, versión y fecha.
- Paquete con mod/mapa compilados, helper Python estándar, lanzadores y guía española.

La latencia seleccionada es **retardo adicional de ida y vuelta**, dividido por igual entre direcciones. Se muestra aparte del ping nativo de UT. No se fuerza el scoreboard a coincidir con el número solicitado.

## Verificación observada antes de la interrupción

Entorno: OldUnreal 469e Linux amd64, viewport SDL/Mesa real y servidor dedicado privado.

| Comprobación | Resultado observado |
| --- | --- |
| Tests Python de herramientas/protocolo/configuración/encoding | 22 pasando |
| Compilación de ambos paquetes UnrealScript | 0 errores, 0 warnings |
| Reconstrucción del mapa propio | PASS, seis polígonos |
| Local: once armas, primario/secundario | 22 casos pasando |
| IGPlus: once armas, primario/secundario | 22 casos pasando |
| Ronda real desde menú y helper | 30 segundos, PASS |
| Pausa/reanudación del servidor desde el menú | PASS |
| HUD y disparo nuevo para volver al selector | PASS |
| Regresión de controles standalone | 26 comprobaciones pasando |
| Regresión de motor dedicado | 52 comprobaciones pasando |
| Extremos de retardo 0 y 300 ms | PASS con cliente/servidor reales |
| Exportación local de beam, sin inventar accuracy cero | PASS |
| ZIP extraído en otra instalación, sin fuentes del proyecto | Bootstrap y recorrido completo PASS |

Las pruebas automáticas usan posiciones controladas de los blancos. El Ripper se comprobó con mano centrada en el fixture para evitar roces de borde/paralaje; el juego normal conserva la configuración del usuario. Estos casos validan el código/atribución de impactos, no la puntería física ni la sensación del mouse.

Ejemplo observado en la instalación extraída del ZIP:

```text
MENUTEST selected IGPlus, Shock, 85 ms and 30 seconds through Start
ROUNDTEST PASS true infinite client ammo
ROUNDTEST PASS server pause while setup is open
ROUNDTEST RESULT weapon=Shock shots=2 hits=2 kills=0 elapsed=30.000000 requested=85 measured=82.882416 game_ping=93
ROUNDTEST PASS weapon, score, timer and result HUD
ROUNDTEST fresh fire acknowledged result
MENUTEST DONE failures=0
```

Los valores de RPC son diagnósticos del reloj del juego; el ping mostrado al jugador proviene de PlayerReplicationInfo.Ping. Un caso de 0 ms adicionales informó ping nativo 18; uno de 300 informó 387. Son observaciones de esas ejecuciones, no garantías ni latencias físicas del mouse.

## Archivos de la implementación pendientes de recuperar/publicar

Los siguientes nombres corresponden al trabajo no publicado, no necesariamente a archivos presentes en main:

- UTAT: UTATWeaponCatalog, UTATNetworkBridge, UTATNetworkState, UTATNetworkHUD, UTATSetupOpener, UTATMenuNetworkTest, UTATArsenalTest.
- Adaptadores locales LC* y LP*, ampliación de UTATGame/UTATPlayer/UTATPanel, ammo simulado infinito y HUD/About.
- UTATNetLab: UTATRoundGame, UTATRoundState, UTATNetShot, UTATNetProjectileNotify, NW* y NP*.
- Helper: start_aimtrainer.py, network_config.py, net_relay.py.
- Tests/paquete: arsenal_smoke.py, package_dev.py, Start-Aimtrainer.cmd y Start-Aimtrainer.sh.
- Guías/evidencia: README, QUICKSTART_ES, VALIDATION, INTEGRATION_SMOKE y resumen español.
- Artefacto generado y probado: dist/UTAT-dev-0.4.0.zip. No hay enlace público confirmado a ese archivo.

Detalles importantes para conservar al recuperar:

1. El SpawnNotify de proyectiles corre solo en servidor; no debe reemplazar indiscriminadamente actores en clientes.
2. Heredar el Instigator original antes de crear el adaptador, para ejecutar correctamente PostBeginPlay.
3. Desactivar la colisión del placeholder original antes de crear el reemplazo, evitando detonaciones prematuras por contacto entre ambos.
4. Conservar owner, posición, rotación, colisión, velocidad, aceleración y física; restaurar el original si falla el reemplazo.
5. Los hijos de explosiones heredan token; un combo dañino acredita orb y traza. No aceptar tokens de otra ronda.
6. Ammo.UseAmmo es simulado y no consume; rellenar solo en servidor no prueba munición infinita en cliente.
7. El controlador de red sigue accesible durante la pausa del nivel; el cierre del menú reanuda por RPC.
8. El helper usa ini de cliente/servidor distintos y no edita los ini normales. Maneja UTF-8/UTF-16/cp1252 y busca un par cliente/UCC completo en System64 o System.
9. Normalmente respeta fullscreen/audio del cliente; las opciones offscreen/windowed/nosound son de prueba.
10. El modo de prueba es opt-in; no debe autoapuntar/disparar durante el uso normal.

## Para cerrar la entrega

1. Recuperar acceso a los archivos del entorno; si no se conservan, reconstruir desde el registro del trabajo y revalidar.
2. Publicar el código nuevo, documentación y ZIP probado; comprobar hashes y descarga pública.
3. Verificar los checks de GitHub de ese commit.
4. Entregar las instrucciones finales al tester, sin presentar el paquete anterior como 0.4.0.

Cuando el paquete esté publicado, el flujo previsto para Windows es: extraer en una copia de UT99 469e, instalar Python 3.10+ y los dos paquetes oficiales de IGPlus 11 por separado, abrir Start-Aimtrainer.cmd y elegir las opciones dentro de UT. Esos pasos todavía no constituyen una entrega descargable confirmada.

Quedan para aceptación posterior: mouse/visual/Windows, detección de .app en macOS, configuración exacta del servidor y hitboxes humanos/ACE. El exportador CSV trabaja con registros locales; NETRESULT de red requiere una ampliación posterior. No se creó ningún GitHub Release ni se desplegó nada en producción.
