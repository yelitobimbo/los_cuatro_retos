# 🪙 Reto 4 · Convertidor de criptomonedas en tiempo real

App que usa la API pública de **CoinGecko** (sin clave) para mostrar el precio de Bitcoin, Ethereum y Solana en dólares. Escribes un monto en USD y ves cuánto de cada cripto podrías comprar.

| | |
|---|---|
| **Alumna** | Yaneli Sánchez Cárdenas |
| **Grupo** | GTID244 |
| **Materia** | Desarrollo de Aplicaciones Móviles |
| **Docente** | Prof. Anastacio Rodríguez García |
| **Universidad** | UTNG |

## 🗺️ Estructura

```
cripto_convertidor/
  lib/
    cripto.dart          <- modelo, parseo, cálculo y formato
    servicio_cripto.dart <- petición a /simple/price
    main.dart            <- TextField + FutureBuilder + ListView
  test/
    cripto_test.dart     <- 10 pruebas (con MockClient, sin internet)
```

Endpoint: `https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd`

## ▶️ Cómo ejecutarlo

Abre la carpeta `cripto_convertidor` en VS Code (**File > Open Folder**) y en la terminal:

```bash
flutter create .                # genera android/, ios/, web/ (no borra lo que ya existe)
del test\widget_test.dart       # (Windows) borra la prueba de ejemplo
flutter pub get
flutter test                    # 10 pruebas, sin internet → "All tests passed!"
flutter run
```

> La API pública tiene límite de consultas. Si sale "Muchas consultas seguidas", espera un minuto y toca 🔄.

## 📸 Evidencias

![Estructura](capturas/01_estructura.png)
![All tests passed](capturas/02_tests.png)

| Precios | Conversión de otro monto | Monto inválido |
|---|---|---|
| ![Precios](capturas/03_precios.png) | ![Conversión](capturas/04_conversion.png) | ![Inválido](capturas/05_invalido.png) |

## 📚 Lo que practiqué

- Convertir texto a número con `double.tryParse` (acepta punto o coma).
- Operaciones con datos dinámicos: `dólares / precio`.
- `FutureBuilder` + `ListView`, y refrescar la pantalla con `setState`.
