# Reto 1 · El recomendador de películas del fin de semana

App que consume la API de **The Movie Database (TMDB)** y recomienda películas según tu estado de ánimo, o muestra las tendencias de la semana. Tiene un botón para escoger una al azar.

| | |
|---|---|
| **Alumna** | Yaneli Sánchez Cárdenas |
| **Grupo** | GTID244 |
| **Materia** | Desarrollo de Aplicaciones Móviles |
| **Docente** | Prof. Anastacio Rodríguez García |
| **Universidad** | UTNG |

## Estructura

```
peliculas_finde/
  lib/
    pelicula.dart            <- modelo Pelicula + desdeJson
    estado_animo.dart        <- estado de ánimo → género de TMDB
    servicio_peliculas.dart  <- peticiones HTTP y parseo del JSON
    main.dart                <- pantalla con chips, lista y tarjetas (Card)
  test/
    peliculas_test.dart      <- 10 pruebas (con MockClient, sin internet)
  secrets.json               <- tu clave (NO se sube a GitHub)
  secrets.json.example
```

| Estado de ánimo | Género |
|---|---|
| Feliz | Comedia (35) |
| Aventurero | Acción (28) |
| Romántico | Romance (10749) |
| Con ganas de miedo | Terror (27) |
| Pensativo | Drama (18) |

## Clave de TMDB

1. Crea una cuenta gratis en themoviedb.org y pide una clave de API (Settings > API).
2. Pega la **API Key** en `secrets.json`:
   ```json
   { "TMDB_KEY": "tu_clave" }
   ```
3. `secrets.json` está en `.gitignore`: nunca lo subas. Revisa con `git status` que no aparezca.

Sin clave, la app corre en **modo demo** con 3 películas de ejemplo.

## Cómo ejecutarlo

Abre la carpeta `peliculas_finde` en VS Code (**File > Open Folder**) y en la terminal:

```bash
flutter create .                # genera android/, ios/, web/ (no borra lo que ya existe)
del test\widget_test.dart       # (Windows) borra la prueba de ejemplo
flutter pub get
flutter test                    # 10 pruebas, sin internet → "All tests passed!"
flutter run --dart-define-from-file=secrets.json
```

## Evidencias

**La app funcionando en el celular** (modo demo, sin clave de TMDB):

<img src="capturas/app_celular.jpg" alt="Películas del finde en el celular" width="300">

## Lo que practiqué

- Peticiones HTTP con el paquete `http` y parámetros en la URL (`Uri.https`).
- Convertir JSON a objetos (`Pelicula.desdeJson`).
- `FutureBuilder` con estado de carga (`CircularProgressIndicator`) y de error.
- Guardar la clave fuera del código con `--dart-define-from-file`.
