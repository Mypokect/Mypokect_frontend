# Integración GoalsScreen ↔ Movements

## Resumen

La pantalla `Movements.dart` ha sido actualizada para recibir parámetros de entrada desde `GoalsScreen`, permitiendo un flujo fluido donde el usuario puede abonar a sus metas de ahorro directamente.

## Cambios Realizados

### 1. lib/Screens/Movements.dart

#### Constructor Actualizado
```dart
class Movements extends StatefulWidget {
   final String? preSelectedTag;
   final bool? isExpense;

   const Movements({
     super.key,
     this.preSelectedTag,      // ← Nuevo: Etiqueta pre-seleccionada
     this.isExpense,            // ← Nuevo: Tipo de movimiento
   });
}
```

#### Nuevo Método de Inicialización
```dart
void _initializeFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;

    // Leer desde RouteSettings
    if (args != null && args is Map<String, dynamic>) {
      final data = args;

      if (data['preSelectedTag'] != null) {
        final tag = data['preSelectedTag'] as String;
        _etiquetaController.text = tag;
        _isTagLocked = true;  // ← Bloquear etiqueta
      }

      if (data['isExpense'] != null) {
        _esGasto = data['isExpense'] as bool;
      }
    }

    // Leer desde constructor
    if (widget.preSelectedTag != null) {
      _etiquetaController.text = widget.preSelectedTag!;
      _isTagLocked = true;
    }

    if (widget.isExpense != null) {
      _esGasto = widget.isExpense!;
    }
}
```

#### Nueva Variable de Estado
```dart
bool _isTagLocked = false;  // ← Controla si el campo de etiquetas está bloqueado
```

#### initState Actualizado
```dart
@override
void initState() {
    super.initState();

    _initializeFromArguments();  // ← Nuevo: Inicializar desde argumentos
    _nombreController.addListener(_onTextChanged);
    _montoController.addListener(_onTextChanged);
    _cargarEtiquetas();
    _initSpeech();
}
```

#### AppBar Mejorada
Cuando la etiqueta está bloqueada, muestra información adicional:
```dart
title: _isTagLocked
    ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _esGasto ? "Registrar Gasto" : "Registrar Ingreso",
            style: TextStyle(
                color: _mainColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            "Meta: ${_etiquetaController.text}",
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
        ],
      )
    : Text(...),
```

#### Campo de Etiquetas Actualizado
```dart
Expanded(
  child: CampoEtiquetas(
    etiquetaController: _etiquetaController,
    etiquetasUsuario: _etiquetasUsuario,
    isLocked: _isTagLocked,  // ← Nuevo: Bloquear si viene de metas
    onEtiquetaSeleccionada: (tag) => setState(() {
      if (!_isTagLocked) {  // Solo permitir cambios si no está bloqueado
        _etiquetaController.text = tag;
      }
    }),
  ),
),
```

### 2. lib/Widgets/movements/campo_etiquetas.dart

#### Nuevo Parámetro
```dart
class CampoEtiquetas extends StatefulWidget {
   final TextEditingController etiquetaController;
   final List<String> etiquetasUsuario;
   final ValueChanged<String> onEtiquetaSeleccionada;
   final bool isLocked;  // ← Nuevo: Controla si el campo está bloqueado

   const CampoEtiquetas({
     super.key,
     required this.etiquetaController,
     required this.etiquetasUsuario,
     required this.onEtiquetaSeleccionada,
     this.isLocked = false,  // ← Valor por defecto: false
   });
}
```

#### TextField Actualizado
```dart
child: TextField(
  controller: textEditingController,
  focusNode: focusNode,
  enabled: !widget.isLocked,  // ← Deshabilitado si está bloqueado
  decoration: InputDecoration(
    hintText: 'Etiqueta',
    border: InputBorder.none,
    filled: widget.isLocked,      // ← Fondo gris si está bloqueado
    fillColor: widget.isLocked ? Colors.grey[300] : null,
  ),
  style: TextStyle(
    fontSize: 16,
    color: widget.isLocked ? Colors.grey[600] : Colors.black,  // ← Texto gris si está bloqueado
  ),
),
```

## Flujo Completo

### Desde GoalsScreen
```dart
void _handleContribute(Map<String, dynamic> goal) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Movements(),
      settings: RouteSettings(
        arguments: {
          'preSelectedTag': goal['name'] as String,  // "Vacaciones en Europa"
          'isExpense': false,                         // Configurar como ingreso
        },
      ),
    ),
  );
}
```

### En Movements (Recepción)
```dart
// 1. initState() llama a _initializeFromArguments()
// 2. Se leen los argumentos desde RouteSettings
// 3. Se pre-llena el campo de etiquetas
// 4. Se bloquea el campo de etiquetas (_isTagLocked = true)
// 5. Se configura el tipo como "Ingreso" (_esGasto = false)
// 6. La AppBar muestra: "Registrar Ingreso" + "Meta: Vacaciones en Europa"
// 7. El usuario solo necesita ingresar el monto y opcionalmente la descripción
```

## Comportamiento del Usuario

### Escenario Normal (Sin argumentos)
```
1. Usuario abre Movements desde menú
2. Todos los campos están disponibles
3. Tipo predeterminado: "Gasto"
4. Etiqueta: editable y con autocompletado
5. AppBar: "Registrar Gasto"
```

### Escenario desde Metas (Con argumentos)
```
1. Usuario toca "Abonar" en "Vacaciones en Europa"
2. Se abre Movements
3. AppBar: "Registrar Ingreso" + "Meta: Vacaciones en Europa"
4. Tipo: "Ingreso" (se cambia automáticamente)
5. Campo de etiquetas:
   - Pre-llenado con "Vacaciones en Europa"
   - Bloqueado (fondo gris)
   - No permite edición
   - No muestra autocompletado
6. Campo de descripción: disponible (opcional)
7. Campo de monto: disponible (obligatorio)
8. Método de pago: disponible
9. Factura: disponible (pero oculta en ingresos)
10. Usuario solo necesita poner el monto y tocar "Guardar"
```

## UX Mejorada

### Indicadores Visuales
- ✅ **Etiqueta bloqueada**: Fondo gris, texto gris, deshabilitado
- ✅ **AppBar informativa**: Muestra el nombre de la meta
- ✅ **Tipo automático**: Cambia a "Ingreso" sin intervención del usuario
- ✅ **Pre-llenado**: La etiqueta ya está lista

### Prevención de Errores
- ✅ El usuario no puede cambiar la etiqueta por error
- ✅ El tipo de movimiento se configura automáticamente
- ✅ La información de la meta es visible en la AppBar

## Verificación de Calidad

```bash
flutter analyze lib/Screens/movements.dart lib/Widgets/movements/campo_etiquetas.dart
# Resultado: No issues found!
```

## Próximas Mejoras Opcionales

### 1. Botón "Cambiar Meta"
Si el usuario quiere abonar a otra meta:
```dart
if (_isTagLocked) {
  // Agregar un icono de desbloquear
  IconButton(
    icon: Icon(Icons.edit, size: 18),
    onPressed: () => setState(() => _isTagLocked = false),
  ),
}
```

### 2. Badge de "Desde Metas"
Pequeño indicador en la AppBar:
```dart
actions: [
  if (_isTagLocked)
    Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Chip(
        label: Text("Meta", style: TextStyle(fontSize: 11)),
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
    ),
],
```

### 3. Navegación Directa al Guardar
Si el usuario viene de metas y guarda, volver a la pantalla de metas:
```dart
if (mounted) {
  if (_isTagLocked) {
    Navigator.popUntil(context, (route) => route.settings.name == '/goals');
  } else {
    Navigator.pop(context);
  }
}
```

## Resumen Técnico

- **Archivos modificados**: 2
  - `lib/Screens/Movements.dart`
  - `lib/Widgets/movements/campo_etiquetas.dart`
- **Nuevas variables**: 1 (`_isTagLocked`)
- **Nuevos métodos**: 1 (`_initializeFromArguments()`)
- **Parámetros agregados**: 2 (`preSelectedTag`, `isLocked`)
- **Líneas de código agregadas**: ~30
- **Análisis estático**: ✅ Sin errores ni warnings
