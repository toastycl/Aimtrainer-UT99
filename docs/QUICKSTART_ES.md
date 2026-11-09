# Primera prueba de Aimtrainer UT99

Alpha local para CTF con armas normales. Esta etapa usa Shock primario, blancos de flick y strafe. El mapa propio, tracking continuo, combos y cambio automático de input quedan pendientes.

## Compilar e instalar

Usa Python 3.10+ y una instalación completa de UT99 de prueba con OldUnreal 469e. Cierra el juego.

```powershell
py scripts/build.py --ut-root "C:\Games\UnrealTournament" --system System
```

En Linux/macOS usa `python3`, tu ruta real y `--system` si el compilador está en otra carpeta. Un build correcto produce `dist/UTAT-alpha-0.1.0.zip`. Copia `System/UTAT.u` y `System/UTAT.int` en el directorio `System` del juego de prueba. No incluye texturas nuevas.

## Entrenar

1. Abre la consola y ejecuta `open DM-Deck16][?Game=UTAT.UTATGame?Mutator=?NumBots=0`, si tienes ese mapa.
2. Busca una zona plana y amplia; mira hacia una vía libre de aproximadamente 700 unidades de largo y 320 de ancho.
3. Abre **Mods > UT99 Aimtrainer**, o usa `AimHelp`.
4. Guarda tu sensibilidad con `AimSave 0`.
5. Usa `AimExercise 0`, `AimDuration 60` y `AimStart` para flicks. Dispara con Shock primario.
6. Cambia con `AimSensitivity 1.8`, guarda `AimSave 1` y repite desde el mismo punto y orientación.
7. Usa `AimExercise 1` para strafe, `AimStop` para cancelar y `AimRestore` para recuperar los ajustes iniciales.

El panel permite seleccionar un slot y aplicarlo o guardarlo por separado. Los slots son 0, 1 y 2. Un slot vacío no reemplaza tus ajustes.

El backend se cambia desde las preferencias originales del cliente. Esta alpha no detecta ni verifica Raw Input, DirectInput o Cursor; el registro indica `unverified`. Anota manualmente input, DPI, polling rate, FPS, renderer y versión del cliente, y mantén condiciones iguales.

## Resultados

Copia el log del juego antes de reiniciarlo (puede sobrescribirse). En Windows suele estar en System; Linux/macOS pueden usar la carpeta de preferencias del usuario.

```powershell
py scripts/analyze.py "C:\Games\UnrealTournament\System\UnrealTournament.log" --out results
```

`sessions.csv` contiene las rondas. `summary.json` agrupa solo las completas bajo condiciones equivalentes. No hay aún una tabla comparativa dentro del juego. Los tiempos incluyen reacción y puntería; no representan latencia física del mouse.

Consulta `docs/VALIDATION.md`: compilación, herramientas y pruebas jugables son verificaciones distintas. Usa una instalación de prueba y conserva tus ini originales; los menús originales y otros mods pueden guardar ajustes por su cuenta.
