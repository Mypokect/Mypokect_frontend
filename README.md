# MyPocket

![Flutter](https://img.shields.io/badge/Flutter-3.6.0+-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.6.0+-0175C2?style=flat-square&logo=dart)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS-lightgrey)

## 📱 Descripción

MyPocket es una aplicación móvil de finanzas personales diseñada para ayudar a los usuarios a gestionar sus finanzas de manera intuitiva y eficiente. La aplicación permite registrar movimientos financieros, crear presupuestos, establecer metas de ahorro, programar transacciones recurrentes y recibir asesoramiento sobre impuestos.

## ✨ Características Principales

### Gestión Financiera
- **Registro de Movimientos**: Ingreso y registro de gastos e ingresos con categorización
- **Métodos de Pago**: Soporte para múltiples métodos de pago (efectivo, tarjeta, transferencia, etc.)
- **Etiquetas Personalizadas**: Organización de transacciones con etiquetas personalizadas
- **Entrada de Voz**: Grabación de voz para registrar movimientos rápidamente
- **Análisis Financiero**: Visualización de datos con gráficos interactivos

### Presupuestos
- **Presupuestos por Categoría**: Creación y seguimiento de presupuestos por categoría
- **Alertas de Gasto**: Notificaciones cuando se supera el límite de presupuesto
- **Modo de Ahorro**: Switch para activar/desactivar modo de ahorro
- **Validación de Montos**: Validación en tiempo real de montos de presupuesto

### Ahorros
- **Metas de Ahorro**: Establecimiento de metas de ahorro personalizadas
- **Seguimiento de Progreso**: Visualización del progreso hacia las metas
- **Asistente de Ahorros**: Guías y recomendaciones para optimizar ahorros

### Calendario y Recordatorios
- **Calendario Interactivo**: Vista de calendario con transacciones programadas
- **Transacciones Recurrentes**: Programación de pagos recurrentes (suscripciones, facturas)
- **Notificaciones Locales**: Recordatorios automáticos para fechas importantes
- **Gestión de Eventos**: Agregar, editar y eliminar eventos del calendario

### Impuestos
- **Asistente de Impuestos**: Asistente para calcular y gestionar obligaciones fiscales
- **Tax Radar**: Seguimiento de fechas límite de impuestos
- **Motor de Impuestos**: Cálculo automático de impuestos según normativa vigente

### Autenticación y Seguridad
- **Registro y Login**: Sistema de autenticación completo
- **Almacenamiento Seguro**: Uso de SharedPreferences para datos sensibles
- **Sesiones Persistentes**: Mantenimiento de sesión activa

### Interfaz de Usuario
- **Diseño Material Design**: Interfaz moderna y intuitiva
- **Tema Personalizado**: Colores corporativos (#006B52 verde, #03DAC6 teal)
- **Fuente Personalizada**: Fuente Baloo2 para mejor legibilidad
- **Animaciones Suaves**: Transiciones y animaciones fluidas
- **Internacionalización**: Soporte para español e inglés

## 🛠️ Tecnologías y Dependencias

### Core
- **Flutter**: ^3.6.0 - Framework de desarrollo multiplataforma
- **Dart**: ^3.6.0 - Lenguaje de programación

### Comunicación
- **http**: ^1.4.0 - Cliente HTTP para peticiones a la API

### Almacenamiento Local
- **shared_preferences**: ^2.5.3 - Almacenamiento local de clave-valor

### UI Components
- **flutter_svg**: ^2.2.0 - Renderizado de SVG
- **table_calendar**: ^3.1.1 - Widget de calendario interactivo
- **fl_chart**: ^1.1.1 - Gráficos y visualizaciones
- **avatar_glow**: ^3.0.1 - Efectos de brillo en avatares
- **flutter_staggered_animations**: ^1.1.1 - Animaciones escalonadas

### Funcionalidades Especiales
- **speech_to_text**: ^7.1.0 - Reconocimiento de voz
- **flutter_local_notifications**: ^17.1.2 - Notificaciones locales
- **permission_handler**: ^11.3.1 - Gestión de permisos
- **timezone**: ^0.9.3 - Gestión de zonas horarias

### Utilidades
- **intl**: ^0.20.2 - Internacionalización y formateo
- **intl_phone_field**: ^3.2.0 - Campo de teléfono internacional
- **hexcolor**: ^3.0.1 - Colores en formato hexadecimal
- **flutter_launcher_icons**: ^0.14.4 - Configuración de iconos de la app
- **rename**: ^3.1.0 - Renombrado del proyecto

### Desarrollo
- **flutter_test**: Framework de pruebas
- **flutter_lints**: ^5.0.0 - Linter para Flutter

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── constants/                         # Constantes de la aplicación
│   ├── api_constants.dart           # URLs y endpoints de la API
│   ├── storage_keys.dart            # Claves de SharedPreferences
│   └── app_strings.dart              # Strings de la aplicación
├── Screens/                          # Vistas de la aplicación
│   ├── Auth/                         # Pantallas de autenticación
│   │   ├── Login.dart               # Pantalla de inicio de sesión
│   │   ├── Register.dart            # Pantalla de registro
│   │   └── splash_screen.dart       # Pantalla de carga
│   ├── home.dart                    # Pantalla principal
│   ├── movements.dart               # Registro de movimientos
│   ├── main_screen.dart             # Navegación principal
│   └── service/                     # Pantallas de servicios
│       ├── calendario_page.dart     # Calendario de transacciones
│       ├── budget_screen.dart       # Gestión de presupuestos
│       ├── budgets_list_screen.dart # Lista de presupuestos
│       ├── savings_assistant_fixed.dart # Asistente de ahorros
│       ├── tax_assistant_screen.dart   # Asistente de impuestos
│       └── tax_radar_screen.dart       # Radar de impuestos
├── Controllers/                      # Lógica de negocio
│   ├── auth_controller.dart         # Controlador de autenticación
│   ├── home_controller.dart         # Controlador de pantalla principal
│   ├── movement_controller.dart     # Controlador de movimientos
│   ├── budget_controller.dart       # Controlador de presupuestos
│   └── scheduled_transaction_controller.dart # Controlador de transacciones programadas
├── api/                             # Clientes de API
│   ├── auth_api.dart               # API de autenticación
│   ├── movement_api.dart           # API de movimientos
│   ├── budget_api.dart             # API de presupuestos
│   ├── savings_api.dart             # API de ahorros
│   ├── scheduled_transaction_api.dart # API de transacciones programadas
│   ├── tax_api.dart                # API de impuestos
│   └── user_api.dart               # API de usuarios
├── Widgets/                         # Componentes de UI reutilizables
│   ├── common/                     # Widgets comunes
│   │   ├── button_custom.dart      # Botón personalizado
│   │   ├── text_input.dart         # Campo de texto
│   │   ├── text_widget.dart        # Widget de texto
│   │   └── CustomAlert.dart        # Alerta personalizada
│   ├── calendar/                   # Widgets de calendario
│   │   ├── calendar_header_widget.dart
│   │   ├── calendar_event_card_widget.dart
│   │   ├── calendar_empty_state_widget.dart
│   │   └── add_reminder_bottom_sheet_widget.dart
│   ├── movements/                  # Widgets de movimientos
│   │   ├── movement_amount_input_widget.dart
│   │   ├── movement_description_input_widget.dart
│   │   ├── payment_method_button_widget.dart
│   │   ├── payment_method_section_widget.dart
│   │   ├── save_button_section_widget.dart
│   │   ├── voice_recording_button_widget.dart
│   │   ├── animated_toggle_switch.dart
│   │   └── campo_etiquetas.dart
│   ├── budget/                     # Widgets de presupuestos
│   │   ├── budget_list_card_widget.dart
│   │   ├── category_card_widget.dart
│   │   ├── category_input_widget.dart
│   │   ├── money_input_widget.dart
│   │   ├── mode_switch_widget.dart
│   │   └── budget_validation_widget.dart
│   ├── savings/                    # Widgets de ahorros
│   │   ├── savings_goal_card_widget.dart
│   │   ├── savings_info_row_widget.dart
│   │   └── savings_tab_switch_widget.dart
│   └── home/                       # Widgets de pantalla principal
│       └── principal_actions_widget.dart
├── Services/                        # Servicios de la aplicación
│   ├── base_url.dart               # Configuración de base URL
│   ├── base_api_service.dart       # Servicio base de API
│   └── notification_service.dart   # Servicio de notificaciones
├── Theme/                           # Tema de la aplicación
│   └── theme.dart                  # Configuración de colores y estilos
├── utils/                           # Utilidades
│   ├── helpers.dart                # Funciones auxiliares
│   └── tax_engine_2023.dart        # Motor de cálculo de impuestos
└── models/                          # Modelos de datos
    └── transaction_occurrence.dart  # Modelo de transacción
```

## 🚀 Instalación y Configuración

### Requisitos Previos

- Flutter SDK >= 3.6.0
- Dart SDK >= 3.6.0
- Android Studio / Xcode (según la plataforma de desarrollo)
- Un dispositivo emulado o físico para pruebas

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd app_movil_finanzas
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Generar iconos de la aplicación**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Configurar el entorno**
   ```bash
   flutter doctor
   ```

5. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📱 Construir para Producción

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recomendado para Google Play)
flutter build appbundle --release
```

### iOS
```bash
# Build para iOS
flutter build ios --release

# Nota: Necesita Xcode y un Mac
```

### macOS
```bash
# Build para macOS
flutter build macos --release
```

## 🧪 Pruebas

### Ejecutar todas las pruebas
```bash
flutter test
```

### Ejecutar pruebas específicas
```bash
flutter test test/widget_test.dart
```

### Ejecutar pruebas con nombre específico
```bash
flutter test --name "test_name"
```

## 🔧 Comandos de Desarrollo

### Análisis de Código
```bash
flutter analyze
```

### Formateo de Código
```bash
flutter format .
```

### Limpiar caché
```bash
flutter clean
flutter pub get
```

### Depuración
```bash
flutter run --debug
flutter run --profile
```

## 🎨 Tema y Estilos

### Colores Principales
- **Color Primario**: `#006B52` (Verde)
- **Color Secundario**: `#03DAC6` (Teal)
- **Color de Fondo**: `#F5F5F5` (Gris claro)
- **Color de Texto**: Negro
- **Color de Error**: Rojo
- **Color Gris**: `#888888`

### Fuente
- **Familia**: Baloo2
- **Pesos Disponibles**: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold), 800 (ExtraBold)

## 🌍 Internacionalización

La aplicación soporta múltiples idiomas:
- Español (es) - Predeterminado
- Inglés (en)

## 📝 Convenciones de Código

### Nombres
- **Clases**: PascalCase (`AuthController`)
- **Archivos**: lowercase_with_underscores (`auth_controller.dart`)
- **Variables**: lowerCamelCase (`userName`)
- **Constantes**: lowerCamelCase (`apiUrl`)
- **Miembros Privados**: Prefijo con `_` (`_loadData`)

### Imports
1. Dart core
2. Flutter imports
3. Package imports
4. Relative project imports

### Linting
El proyecto utiliza `flutter_lints` para mantener la calidad del código. Siempre ejecuta `flutter analyze` antes de realizar commits.

## 🔐 Seguridad

- Los tokens de autenticación se almacenan en SharedPreferences
- No se debe incluir información sensible en el código fuente
- Se deben usar variables de entorno para configuración sensible

## 📄 Licencia

Este proyecto está bajo la Licencia [Tipo de Licencia].

## 👨‍💻 Contribución

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Contacto

- **Proyecto**: MyPocket
- **Versión**: 1.0.0+1
- **Descripción**: Aplicación móvil de finanzas personales

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- Comunidad de Flutter por los paquetes y herramientas
- Todos los contribuidores del proyecto

---

**Nota**: Este es un proyecto de código abierto para la gestión de finanzas personales. Úsalo bajo tu propia responsabilidad.
