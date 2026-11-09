# Resumen de entrega — desarrollo 0.4.0

**ToastyCL · 2026-11-09 (UTC)**

Queda integrado el flujo Local/IGPlus desde el menú: entorno, valor libre de 0 a 300 ms, arma, ejercicio y duración. El botón Start espera a que el servidor esté listo y entra a la sala. Al terminar, las estadísticas aparecen sobre el mundo y un disparo primario nuevo vuelve al selector conservando la selección.

Las once armas clásicas están disponibles en ambos entornos, con secundarios habilitados: Shock, Sniper, Minigun, Pulse, Rocket, Flak, Enforcer, Bio, Ripper, Impact Hammer y Redeemer. Sniper secundario es zoom; Pulse beam muestra tiempo de contacto aparte del accuracy de proyectiles. La munición es infinita. Se mantienen los spawns aleatorios y los blancos estáticos/en movimiento.

IGPlus utiliza su jugador real y adaptadores derivados de sus armas/proyectiles. Se distingue el retardo solicitado del ping informado por UT. El perfil probado es el normal de armas de IGPlus 11; todavía no equivale a certificar la configuración exacta de un servidor o sus hitboxes de jugadores humanos.

## Para probar

1. Extraer el ZIP completo en una copia de UT99 469e, con el juego cerrado.
2. Para IGPlus: instalar Python 3.10+ y los dos paquetes oficiales que indica la guía.
3. Abrir Start-Aimtrainer.cmd, elegir IGPlus y escribir los ms dentro de UT.
4. Probar primero Sniper/estáticos/30 segundos con 0 ms; repetir con 85, 143 y 300. Después cambiar libremente armas y disparos.
5. Comprobar fin automático, resultados, pausa del menú, disparo nuevo para salir, repetición y cierre del juego.

[Guía completa y rutas exactas](QUICKSTART_ES.md) · [Verificaciones ejecutadas y límites](VALIDATION.md).

La comprobación automática usa motor/viewport reales en Linux; no sustituye tu prueba física del mouse ni la aceptación de Windows. El lanzador aún no descubre instalaciones `.app` de macOS. El exportador CSV importa registros locales; los de red quedan por ahora en `NETRESULT`. No se desplegó en servidores ni se creó un release de GitHub.
