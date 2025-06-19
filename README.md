# Plutonium Offline
Este script te permite lanzar juegos de **Call of Duty** compatibles con **Plutonium** en modo **offline**, sin necesidad de conexión ni cuenta en línea (también es compatible para jugar en LAN).\
Probado su funcionamiento en Windows 10 (Versión 22H2) y Windows 11 (Versión 24H2), pero debería funcionar sin problemas desde Windows 10 (Versión 1803) en adelante.

## Juegos compatibles
- Call of Duty: World at War
- Call of Duty: Black Ops
- Call of Duty: Modern Warfare 3
- Call of Duty: Black Ops II

## Instrucciones de uso
1. Descargá y extraé [la última versión](https://github.com/SoyRA/Plutonium_Offline/archive/refs/heads/main.zip) en cualquier carpeta.
2. Mové el archivo `Plutonium_Offline.bat` a la carpeta de uno de los juegos compatibles.
3. *(Opcional)* Abrilo con el *bloc de notas* u otro editor de texto para modificar las [variables personalizables](#variables-personalizables) a tu gusto.
4. Dale doble click para iniciarlo y seguí las instrucciones en pantalla.

### Variables personalizables
https://github.com/SoyRA/Plutonium_Offline/blob/e3da5930e3390bbfad163061636ef3af5c0f189c/Plutonium_Offline.bat#L21-L42

> Si querés usar códigos de color (`^0` a `^9`) en tu nombre dentro del juego o poner cualquier [carácter de escape](https://ss64.com/nt/syntax-esc.html), encerrá toda la variable entre "comillas".\
> Por ejemplo: `SET "PLAYER_NAME=^1Test"`
>
> Pero lo ideal es que uses caracteres alfanuméricos, así ni Batch ni Plutonium ni el Juego sufren. :v

## Agradecimientos
- [SS64](https://ss64.com/nt/) - Por toda la documentación y recursos, hizo más fácil todo.
- [JoseX](https://github.com/JoseX-cl) - Por probar el script como si tuviera 8 años.
- [M4RCK5](https://github.com/M4RCK5) - Porque su script insostenible y [aprueba de idiotas](https://discord.com/channels/290238678352134145/940996951585988628/1375884787289554954) me inspiró en hacer algo mejor.

<p align="center">Creado con &#x1F92C; por <strong>SoyRA</strong></p>

## Hoja de ruta
- [X] Inicialización
- [X] Variables personalizables
- [X] Variables internas
- [X] Detección de Plutonium
- [X] Detección de juegos
- [X] Menú principal
- [X] Menú por juego
- [X] Lanzamiento del juego
- [X] Modo portable
- [X] Descarga y ejecución de `plutonium.exe` a elección
- [X] Comprobar actualizaciones
- [X] Validación del nombre del jugador
- [X] Verificar rutas con caracteres especiales
- [X] Determinar si Plutonium y/o el juego están en OneDrive
- [ ] Agregar easter eggs

## Aviso
1. La idea original del script era mejorar y unificar lo que [ya había hecho hace años](https://github.com/SoyRA/PlutoT6/blob/master/PlutoT6/PU.bat), pero con algo más de comprobaciones. Fue muy divertido simular funciones y variables locales en Batch :v y limitarme a intentar no usar software de terceros (por eso utilizo el Plutonium Updater oficial y no una alternativa con soporte CLI).
2. No voy a hacer más magia en un archivo .bat, así que no pienso hacer más verificaciones como decirte "che pibe, tu SO no tiene esto la ctm >:v!" xd
3. VIVA LA Ñ! VIVA ESCRIBIR CÓDIGO EN 2 IDIOMAS AAAAAAAAAAAA
