# WalletApp — maqueta de una wallet cripto en SwiftUI

Interfaz completa de una wallet de criptomonedas (inicio con balance y cartera, detalle de
activo con historial, y una pantalla de cambio entre activos), pensada como pieza de
portafolio para mostrar composición de vistas, manejo de estado con `@Observable` y
cálculo monetario con `Decimal` en un dominio financiero real: precios, tenencias y
conversiones.

<img width="1342" height="779" alt="WalletApp" src="https://github.com/user-attachments/assets/83c3c0fc-bcf5-46e2-8186-8781769e8b91" />

---

## Tecnologías usadas

- Swift 6, con verificación estricta de concurrencia
- SwiftUI
- `@Observable`, `@MainActor`
- `Decimal` para todo cálculo monetario (precios, tenencias, historial, tasa de cambio)
- Swift Testing para pruebas
- Integración continua con GitHub Actions
- Cero dependencias externas

---

## Cómo está organizado el proyecto

```
WalletApp/
├── App/                  RouterView y punto de entrada
├── Core/
│   ├── Domain/           Asset, Holding, Transaction, WalletRepository, formateo de Decimal
│   ├── Data/              MockWalletRepository (datos en memoria)
│   └── DesignSystem/      Tokens de color/espaciado/tipografía y componentes reutilizables
└── Features/
    ├── Home/              Balance, banner de depósito, lista de activos
    ├── AssetDetail/        Detalle de un activo con su historial
    └── Swap/                Cambio entre dos activos con keypad propio
```

Cada pantalla sigue el mismo patrón: una `View` en SwiftUI y un `@Observable @MainActor`
`ViewModel` que habla con `WalletRepository` (un protocolo, para que la UI no conozca la
fuente de datos).

---

## Cómo funciona / flujo principal

1. **Inicio** muestra el balance total de la cartera (suma de `precio × tenencia` de cada
   activo, en `Decimal`), con un botón para ocultarlo, y la lista de activos con su precio,
   variación diaria y posición.
2. Tocar un activo abre su **detalle**: tenencia, valor en USD y el historial de
   transacciones de ese activo específico.
3. El botón "Cambiar" (desde el inicio o desde el detalle de un activo) abre **Swap**: se
   elige cuánto entregar con un keypad numérico, se calcula lo que se recibe según la
   relación de precios entre los dos activos, y se puede invertir el sentido del cambio.
4. Confirmar un cambio actualiza las tenencias de ambos activos y registra una transacción
   de tipo *swap* en el historial de cada uno — en memoria, para la duración de la sesión.

---

## Funcionalidades / qué demuestra

- Cálculo de cartera y de un cambio de activos usando `Decimal` de punta a punta (nunca
  `Double` para dinero), incluyendo el formateo a moneda con locale fijo.
- Repositorio mock con estado mutable protegido por `@MainActor`, para que una acción del
  usuario (el swap) se refleje de inmediato en el resto de la app sin backend real.
- Un único componente de icono de activo (`AssetIcon`) reutilizado en las tres pantallas.
- Ocultar/mostrar balance, descartar el banner de depósito, navegación entre las tres
  pantallas.

---

## Qué es solo visual (a propósito)

Es una maqueta de UI, no una wallet real:

- Los precios y activos son fijos (`MockWalletRepository`); no hay cotizaciones en vivo.
- Enviar, recibir, comprar, buscar y notificaciones son botones sin acción — quedan como
  superficie visual, no como flujos implementados.
- El cambio entre activos sí queda registrado, pero solo en memoria: al reiniciar la app
  vuelve a los datos de partida. No hay persistencia en disco ni backend.
- No hay claves, direcciones ni conexión a ninguna red cripto real.

---

## Pruebas

19 pruebas con Swift Testing sobre la lógica de negocio (sin UI):

- `SwapViewModel` — tasa de cambio, cálculo del monto a recibir, entrada del keypad
  (incluye el separador decimal), `canSwap` contra el saldo disponible, invertir el swap,
  y que confirmar un cambio actualice tenencias y transacciones (o no haga nada si el
  monto no es válido).
- `HomeViewModel` — carga de activos/tenencias y cálculo del balance total.
- `AssetDetailViewModel` — valor de la tenencia y orden del historial por fecha.
- Formateo monetario (`Decimal.formattedUSD`/`formattedAmount`) y parseo del texto del
  keypad.

```bash
xcodebuild test \
  -project WalletApp.xcodeproj \
  -scheme WalletApp \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

---

## Cómo correr el proyecto

1. Clonar el repositorio y abrir `WalletApp.xcodeproj` en Xcode 26 o superior.
2. Seleccionar el esquema `WalletApp` y un simulador de iOS 26.
3. Ejecutar (⌘R). No requiere configuración adicional ni claves de API.

---

## Autor

Stephano Portella
