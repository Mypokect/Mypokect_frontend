// Archivo: lib/main.dart (CORREGIDO Y FINAL)

import 'package:MyPocket/Screens/Auth/Login.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- 1. AÑADE ESTOS DOS IMPORTS ---
import 'package:timezone/data/latest.dart' as tz;
import '/services/notification_service.dart';// Asegúrate de que esta ruta sea correcta

void main() async {
  // Asegura que los bindings de Flutter estén listos (esto ya lo tenías y es correcto)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa el formato de fechas para español (esto ya lo tenías y es correcto)
  await initializeDateFormatting('es_ES', null); 
  
  // --- 2. AÑADE ESTAS LÍNEAS DE INICIALIZACIÓN (LA CORRECCIÓN) ---
  
  // Inicializa el paquete de zonas horarias. Es crucial para programar notificaciones.
  tz.initializeTimeZones(); 
  
  // Crea una instancia de tu servicio de notificaciones
  final notificationService = NotificationService();
  // Inicializa el servicio
  await notificationService.init();
  // Pide permiso al usuario para enviar notificaciones al iniciar la app
  await notificationService.requestPermissions();
  // -----------------------------------------------------------------

  // Finalmente, ejecuta la aplicación (esto ya lo tenías y es correcto)
  runApp(const EasyEconomi());
}

// =================================================================
// === NINGÚN CAMBIO DE AQUÍ PARA ABAJO ===
// =================================================================

class EasyEconomi extends StatelessWidget {
  const EasyEconomi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // --- CONFIGURACIÓN DE IDIOMA (SIN CAMBIOS) ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],
      locale: const Locale('es'),
      // ---------------------------------------------

      home: Login(),
    );
  }
}