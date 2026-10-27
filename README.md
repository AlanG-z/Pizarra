# Pizarra

[![CI](https://github.com/AlanG-z/Pizarra/actions/workflows/ci.yml/badge.svg)](https://github.com/AlanG-z/Pizarra/actions/workflows/ci.yml)

Anotador de puntos para juegos de cartas argentinos, hecho con Flutter.

## Qué hace

Pizarra permite llevar el tanteador de dos juegos clásicos:

### Truco

- Anotador por equipos: 2 o 3 jugadores por lado.
- Puntos dibujados como **trazos de tiza** (o fósforos, palitos o puntos) sobre
  tarjetas translúcidas, en vez de cuadrados rígidos: 3 "malas" arriba y 3
  "buenas" abajo, separadas por una línea punteada.
- Controles `-1`, `+2`, `+3` (mano, envido, truco) y toque en la columna para
  sumar 1.
- Gana el primero en llegar a **30** puntos.
- Página de estilo: tema de la app, forma de los trazos y color.

### Chinchón

- Anotador individual para **2 a 6** jugadores.
- Estilo eliminación: cada jugador suma los puntos de las cartas que le
  quedaron; al alcanzar el límite (por defecto **100**, configurable como
  "Puntos de eliminación") queda eliminado. **Gana el último en pie.**
- Botón `+` con diálogo numérico (teclado, chips `0/+5/+10/+20`, "Cerró (0)").
- Botón `-10` para corregir: descuenta 10 en el acto y el total puede quedar en
  negativo (no se limita a cero).
- Cada jugador tiene su cuenta tipo libreta con todas las jugadas
  (`+N` en verde, `-N` en rojo) como chips, con autoscroll a la última.
- El total se anima al cambiar y pasa a amarillo al 80 % del límite y a rojo al
  llegar.

### Temas

Toda la app (inicio, configuración y puntajes) comparte el mismo lenguaje
visual. Desde la página de estilo se elige entre cuatro temas, y la elección
queda guardada:

| Tema | Fondo | Trazos |
|---|---|---|
| **Paño verde** | Degradé `#0B3D2E` → `#04180F` | Tiza clara |
| **Pizarrón** | Gris carbón | Tiza clara |
| **Papel** | Crema claro | Carbón |
| **AMOLED** | Negro puro | Tiza clara |

Los temas definen la paleta semántica (fondo, superficies translúcidas, textos,
divisorias, acentos y colores de equipo), así que no hay colores fijos en las
pantallas. Los títulos y totales usan la tipografía manuscrita **Patrick Hand**,
incluida como asset.

### Persistencia

La partida en curso se guarda automáticamente en el dispositivo
(`shared_preferences`). Si cerrás la app a mitad de un partido, al volver a
abrirla aparece la sección **PARTIDAS EN CURSO** en la pantalla de inicio con un
acceso para continuar el Truco o el Chinchón donde quedó, incluidos los nombres,
los puntajes, la cuenta de cada jugador y los eliminados. También se recuerdan el
tema de la app y el estilo elegido para el anotador de Truco.

## Stack

| Componente | Detalle |
|---|---|
| Framework | Flutter 3.47+ / Dart 3.13+ |
| UI | Material 3 + 4 temas propios (`AppPalette` como `ThemeExtension`) |
| Tipografía | Patrick Hand (manuscrita, `assets/fonts/`) |
| Estado | `StatefulWidget` + modelos puros (sin gestor externo) |
| Persistencia | `shared_preferences` |
| Lints | `flutter_lints` (`analysis_options.yaml`) |
| CI | GitHub Actions: `flutter analyze` + `flutter test` |
| Plataformas | Android, Linux y Web |

## Estructura

```
lib/
├── main.dart                     # Entry point (GameStorage + tema guardado)
└── src/
    ├── app.dart                  # MaterialApp, tema activo, transiciones fade
    ├── models/                   # Lógica pura, sin widgets
    │   ├── truco_game.dart       # Puntajes, cuadrados, ganador
    │   ├── chinchon_game.dart    # Totales, cuenta, eliminación
    │   └── truco_style.dart      # Estilo del anotador (forma y color)
    ├── routes/routes.dart        # Rutas con nombre
    ├── services/
    │   └── game_storage.dart     # Persistencia en SharedPreferences
    ├── theme/
    │   ├── app_palette.dart      # 4 paletas + ThemeData
    │   └── theme_controller.dart # Tema activo (ValueNotifier)
    ├── widgets/
    │   ├── app_background.dart   # Degradé del tema
    │   ├── fade_slide_in.dart    # Entrada de tarjetas
    │   └── match_painter.dart    # Tiza, fósforos, palitos, divisorias
    └── pages/
        ├── inicio_page.dart      # Selector de juego + partidas en curso
        ├── truco/                # setup_page, score_page, style_page
        └── chinchon/             # setup_page, score_page

test/
├── models/                       # Unit tests de la lógica de puntaje
├── services/                     # Tests de persistencia (partidas, estilo, tema)
├── resume_test.dart              # Continuar partida desde el inicio
├── theme_test.dart               # Paletas, temas y cambio de tema en vivo
├── layout_test.dart              # Ninguna pantalla desborda (4 temas × 2 tamaños)
└── widget_test.dart              # Tests de widgets de ambas páginas
```

La lógica de puntaje (tope de 30 en Truco, eliminación en Chinchón, reparto de
palitos por cuadrado, serialización) vive en `lib/src/models/` como clases Dart
puras, sin dependencias de Flutter. Las páginas solo se encargan de dibujar y
delegar los cambios al modelo.

## Desarrollo

```bash
flutter pub get        # instalar dependencias
flutter analyze        # análisis estático (debe quedar limpio)
flutter test           # unit + widget tests
flutter run -d linux   # o -d chrome, o un emulador/dispositivo android
```

Correr un subconjunto de tests:

```bash
flutter test test/models/
flutter test test/widget_test.dart
flutter test test/layout_test.dart
flutter test --plain-name "ChinchonGame"
```

## Build de release

### APK (instalación directa)

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

Por ABI (APKs más chicos):

```bash
flutter build apk --split-per-abi --release
# → app-{arm64-v8a,armeabi-v7a,x86_64}-release.apk
```

### App Bundle (Google Play)

```bash
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

### Web

```bash
flutter build web --release
# → build/web/
```

### Firma del release

El `build.gradle.kts` actual firma con la clave de debug, que **no sirve para
publicar**. Para generar una firma propia:

1. Crear el keystore (guardarlo fuera del repo):

   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Crear `android/key.properties` (ya está en `.gitignore`):

   ```properties
   storePassword=TU_PASSWORD
   keyPassword=TU_PASSWORD
   keyAlias=upload
   storeFile=/home/TU_USUARIO/upload-keystore.jks
   ```

3. En `android/app/build.gradle.kts`, cargar las propiedades y declarar
   `signingConfigs`:

   ```kotlin
   import java.util.Properties
   import java.io.FileInputStream

   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }

   android {
       // ...
       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String
               keyPassword = keystoreProperties["keyPassword"] as String
               storeFile = file(keystoreProperties["storeFile"] as String)
               storePassword = keystoreProperties["storePassword"] as String
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
           }
       }
   }
   ```

4. Verificar la firma antes de subir:

   ```bash
   flutter build appbundle --release
   keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
   ```

### Checklist para publicar

- [ ] `version: X.Y.Z+N` en `pubspec.yaml` con un `+N` (versionCode) nuevo por
      cada subida a Play.
- [ ] Keystore + `key.properties` configurados (pasos de arriba).
- [ ] `applicationId` definitivo (**ya no se puede cambiar** después de la
      primera publicación): hoy es `io.github.alangz.pizarra`.
- [ ] Icono adaptativo de Android (opcional pero recomendado para Android 8+).
- [ ] Política de privacidad: la app no recolecta datos ni pide permisos.

## Identificadores

| Campo | Valor |
|---|---|
| Paquete Dart | `pizarra` |
| Application ID / namespace Android | `io.github.alangz.pizarra` |
| Linux `APPLICATION_ID` | `io.github.alangz.pizarra` |
| Título de la app | Pizarra |

## Icono

`assets/static.png` (2000×2000) es la imagen fuente. Está declarada en
`pubspec.yaml` y se usó para generar los iconos de Android en todas las
densidades (`android/app/src/main/res/mipmap-*`) y los de la PWA
(`web/icons/Icon-192.png`, `Icon-512.png` y sus variantes *maskable*).

## Tipografía

`assets/fonts/PatrickHand-Regular.ttf` (Patrick Hand, de Google Fonts) se usa
solo en títulos y totales mediante `palette.display(...)`; el resto del texto
usa la fuente del sistema. La licencia SIL Open Font License está en
`assets/fonts/OFL.txt`.

## Licencia

[MIT](LICENSE) © 2026 AlanG-z.
