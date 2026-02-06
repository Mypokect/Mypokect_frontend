# Fix para Error de Ruta de Metas de Ahorro

## 🐛 El Problema

### Error del Backend
```
/8. METAS DE AHORRO (Saving Goals)
    Route::apiResource('saving-goals', SavingGoalController::class);
```

El backend Laravel está buscando la ruta **`saving-goals`** (con guión) pero nuestra API Flutter estaba usando **`/savings/goals`** (con slash).

### Causa del Error

Mismatch entre el nombre del endpoint en Flutter y la ruta configurada en Laravel:
- ❌ Flutter: `/savings/goals`
- ✅ Laravel: `/saving-goals`

## ✅ La Solución

He actualizado todos los endpoints en `lib/api/savings_goals_api.dart` para usar **`saving-goals`** (con guión):

### 1. Método `getGoals()` - GET
```dart
// Antes:
final url = Uri.parse('${BaseUrl.apiUrl}savings/goals');

// Después:
final url = Uri.parse('${BaseUrl.apiUrl}saving-goals');  // ← Cambiado a guión
```

### 2. Método `createGoal()` - POST
```dart
// Antes:
final url = Uri.parse('${BaseUrl.apiUrl}savings/goals');

// Después:
final url = Uri.parse('${BaseUrl.apiUrl}saving-goals');  // ← Cambiado a guión
```

### 3. Método `updateGoal()` - PUT
```dart
// Antes:
final url = Uri.parse('${BaseUrl.apiUrl}savings/goals/$id');

// Después:
final url = Uri.parse('${BaseUrl.apiUrl}saving-goals/$id');  // ← Cambiado a guión
```

### 4. Clave de Respuesta Actualizada
```dart
// Ahora busca también 'saving_goals':
final List<dynamic> list = json['data']
  ?? json['goals']
  ?? json['saving_goals']  // ← Agregado
  ?? [];
```

## 📋 Resumen de Cambios

| Método | Endpoint Anterior | Endpoint Actual | Cambio |
|--------|------------------|-----------------|---------|
| `getGoals()` | `/savings/goals` | `/saving-goals` | ✅ Guión |
| `createGoal()` | `/savings/goals` | `/saving-goals` | ✅ Guión |
| `updateGoal()` | `/savings/goals/{id}` | `/saving-goals/{id}` | ✅ Guión |

## 🔧 Configuración Requerida en Laravel

Para que esto funcione, tu backend Laravel debe tener esta configuración:

### `routes/api.php` o `api.php`
```php
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('saving-goals', SavingGoalController::class);
    //                                    ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
    //                                    DEBE SER 'saving-goals'
    //                                    (con guión)
});
```

### Controller Esperado: `SavingGoalController`
```php
// app/Http/Controllers/SavingGoalController.php

class SavingGoalController extends Controller
{
    public function index()
    {
        // GET /api/saving-goals
        return response()->json([
            'data' => auth()->user()->savingGoals,
        ]);
    }

    public function store(Request $request)
    {
        // POST /api/saving-goals
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'tag' => 'required|string|max:100',
            'target_amount' => 'required|numeric|min:0',
            'emoji' => 'required|string|max:50',
            'icon' => 'required|string|max:50',
            'color' => 'required|string|max:20',
        ]);

        $goal = auth()->user()->savingGoals()->create($validated);
        return response()->json(['data' => $goal], 201);
    }

    public function update(Request $request, $id)
    {
        // PUT /api/saving-goals/{id}
        $goal = auth()->user()->savingGoals()->findOrFail($id);
        $goal->update(['current_amount' => $request->current_amount]);
        return response()->json(['data' => $goal]);
    }

    public function destroy($id)
    {
        // DELETE /api/saving-goals/{id}
        $goal = auth()->user()->savingGoals()->findOrFail($id);
        $goal->delete();
        return response()->json(null, 204);
    }
}
```

### Migration (Tabla en Base de Datos)
```php
// database/migrations/xxxx_create_saving_goals_table.php

Schema::create('saving_goals', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    $table->string('name');
    $table->string('tag')->nullable();
    $table->string('emoji', 50)->nullable();
    $table->string('icon', 50)->nullable();
    $table->string('color', 20)->default('#4CAF50');
    $table->decimal('target_amount', 15, 2);
    $table->decimal('current_amount', 15, 2)->default(0);
    $table->timestamps();

    $table->foreign('user_id')->references('users')->onDelete('cascade');
});
```

### Model
```php
// app/Models/SavingGoal.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SavingGoal extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'tag',
        'emoji',
        'icon',
        'color',
        'target_amount',
        'current_amount',
    ];

    protected $casts = [
        'target_amount' => 'decimal:2',
        'current_amount' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function getProgressAttribute()
    {
        if ($this->target_amount == 0) {
            return 0;
        }
        return min(100, round(($this->current_amount / $this->target_amount) * 100));
    }
}
```

## ✅ Verificación

```bash
flutter analyze lib/api/savings_goals_api.dart
# Resultado: No issues found!
```

## 🧪 Flujo Completo Arreglado

### Flutter → Laravel

```
1. Usuario abre GoalsScreen
2. GoalsScreen llama: getGoals()
3. API hace: GET /api/saving-goals
4. Laravel recibe: SavingGoalController@index()
5. Laravel consulta: saving_goals del usuario
6. Laravel retorna: JSON con 'data'
7. Flutter parsea y muestra las metas
```

```
1. Usuario toca "Abonar" en meta
2. Navega a Movements
3. Usuario guarda abono
4. API hace: PUT /api/saving-goals/{id}
5. Laravel recibe: SavingGoalController@update()
6. Laravel actualiza: current_amount de la meta
7. Flutter actualiza UI con nuevo monto
```

```
1. Usuario crea nueva meta
2. API hace: POST /api/saving-goals
3. Laravel recibe: SavingGoalController@store()
4. Laravel valida datos
5. Laravel crea nueva meta
6. Laravel retorna: JSON con 'data'
7. Flutter agrega meta a la lista
```

## 🚨 Notas Importantes

1. **Autenticación**: Todos los endpoints requieren el header `Authorization: Bearer {token}`
2. **Formato de Respuesta**: Laravel debe retornar siempre la estructura `{'data': ...}` para consistencia
3. **Validación**: Laravel debe validar los datos antes de guardar
4. **Relación**: La tabla `saving_goals` debe tener `user_id` como foreign key

## 🎯 Próximos Pasos

1. ✅ Verificar que Laravel tenga el controlador `SavingGoalController`
2. ✅ Verificar que la ruta `saving-goals` esté configurada
3. ✅ Verificar que la tabla `saving_goals` exista en la base de datos
4. ✅ Probar crear una nueva meta desde la app
5. ✅ Probar abonar a una meta existente
6. ✅ Verificar que los datos se guarden correctamente

## 📞 Contacto Backend

Si después de estos cambios sigues viendo el error, verifica:

1. **Nombre del Controlador**: ¿Se llama exactamente `SavingGoalController`?
2. **Nombre de la Ruta**: ¿Está configurada como `saving-goals` (con guión)?
3. **Middleware**: ¿Estás usando `auth:sanctum` middleware?
4. **Tabla**: ¿Existe la tabla `saving_goals` en la DB?

El endpoint en Flutter ahora coincide con lo que espera el backend Laravel.
