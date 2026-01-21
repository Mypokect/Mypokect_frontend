# GoalsScreen - Metas de Ahorro

## Descripción

Pantalla principal de metas de ahorro con diseño gamificado y moderno. Presenta un tablero de logros visual donde los usuarios pueden ver su progreso y abonar a sus metas.

## Archivos Creados

### 1. **lib/Screens/goals_screen.dart**
Pantalla principal que integra:
- AppBar sin botón atrás (función principal)
- Widget de resumen con estadísticas
- GridView con tarjetas de metas
- FAB flotante para crear nuevas metas

### 2. **lib/Widgets/goals/goal_card_widget.dart**
Tarjeta individual de meta con:
- Indicador circular de progreso
- Emoji/ícono en el centro
- Nombre y montos
- Botón "Abonar" con gradiente
- Badge de completado cuando alcanza 100%
- Animación de entrada escalonada

### 3. **lib/Widgets/goals/goals_summary_widget.dart**
Widget de resumen superior con:
- Ahorro total en metas
- Metas completadas
- Total de metas
- Porcentaje de completado
- Diseño con gradiente

### 4. **lib/Widgets/goals/circular_progress_widget.dart**
Indicador circular personalizado:
- Borde grueso
- Widget central personalizado
- Animación suave
- Color del progreso

### 5. **lib/constants/goal_colors.dart**
Paleta de colores predefinida:
- 10 colores vibrantes para categorías
- Método para obtener color aleatorio

## Características de Diseño

### Estilo Gamificado
- ✅ Diseño tipo "tablero de logros"
- ✅ Animaciones elásticas al cargar
- ✅ Badges de completado con ícono de trofeo
- ✅ Gradientes en botones de acción
- ✅ Sombras con transparencia del color

### UX Minimalista
- ✅ Tipografía Baloo2 consistente
- ✅ Bordes muy redondeados (24px)
- ✅ Espaciado generoso (20px)
- ✅ Colores vibrantes pero equilibrados

### Interactividad
- ✅ Touch feedback en todas las tarjetas
- ✅ Navegación a Movements con pre-selección
- ✅ Modal de creación de meta elegante
- ✅ Pull-to-refresh (futuro)

## Flujo de Navegación

### Abonar a Meta
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => Movements(),
    settings: RouteSettings(
      arguments: {
        'preSelectedTag': goal['name'],
        'isExpense': false,  // Configurar como ingreso
      },
    ),
  ),
);
```

### Crear Nueva Meta
```dart
_showCreateGoalDialog() {
  // Modal bottom sheet con:
  // - Nombre de la meta
  // - Monto objetivo
  // - Botón "Crear Meta"
}
```

## Integración en la App

### 1. Agregar navegación desde Menú Principal

```dart
// En tu menú o home screen:
ListTile(
  leading: Icon(Icons.flag, color: AppTheme.primaryColor),
  title: Text("Mis Metas"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GoalsScreen()),
    );
  },
)
```

### 2. Recibir datos en Movements.dart

```dart
// En initState() de Movements:
@override
void initState() {
  super.initState();

  final args = ModalRoute.of(context)?.settings.arguments;
  if (args != null) {
    final data = args as Map<String, dynamic>;
    if (data['preSelectedTag'] != null) {
      _etiquetaController.text = data['preSelectedTag'];
    }
    if (data['isExpense'] != null) {
      _esGasto = data['isExpense'];
    }
  }

  // Resto del initState...
}
```

## Datos de Ejemplo

La pantalla incluye 6 metas de ejemplo:

1. **Vacaciones en Europa** ✈️
   - Azul (#2196F3)
   - $3.5M / $8M (44%)

2. **MacBook Pro M3** 💻
   - Púrpura (#9C27B0)
   - $2.8M / $5M (56%)

3. **Auto Nuevo** 🚗
   - Naranja (#FF5722)
   - $15M / $35M (43%)

4. **Fondo de Emergencia** 🏦
   - Verde (#4CAF50)
   - $8.5M / $10M (85%)

5. **PlayStation 5** 🎮
   - Cian (#00BCD4)
   - $1.2M / $3.5M (34%)

6. **Gimnasio Anual** 💪
   - Rosa (#E91E63)
   - $0 / $800K (0%)

## Customización

### Cambiar Colores
Edita `lib/constants/goal_colors.dart`:

```dart
static const Color blue = Color(0xFF2196F3);
// Agrega más colores...
```

### Cambiar Animación
Edita `lib/Widgets/goals/goal_card_widget.dart`:

```dart
_controller = AnimationController(
  vsync: this,
  duration: Duration(milliseconds: 400 + (widget.index * 80)),
);

_scaleAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(CurvedAnimation(
  parent: _controller,
  curve: Curves.elasticOut,  // Cambia aquí
));
```

## Próximos Pasos

1. **Integración con API Backend**
   - Reemplazar datos mock con API calls
   - Implementar CRUD completo de metas
   - Persistencia en servidor

2. **Notificaciones**
   - Alertar cuando meta alcance 80%
   - Celebrar cuando se complete una meta
   - Recordatorios de abono mensual

3. **Funcionalidades Adicionales**
   - Edición de metas existentes
   - Eliminación de metas
   - Compartir progreso en redes sociales
   - Exportar reporte PDF

## Análisis de Calidad

```bash
flutter analyze lib/Screens/goals_screen.dart lib/Widgets/goals/*.dart
# Resultado: No issues found!
```

## Capturas

La pantalla presenta:
- **Resumen superior** con gradiente verde y estadísticas
- **Grid 2 columnas** con tarjetas grandes y animadas
- **FAB central** flotante con "Nueva Meta"
- **Tarjetas** con indicador circular, emoji, nombre, montos y botón de acción
- **Badge de trofeo** en metas completadas
