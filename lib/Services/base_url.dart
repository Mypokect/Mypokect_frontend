class BaseUrl {
  // Configuración para diferentes entornos:
  // - Android Emulator: usa 10.0.2.2
  // - Dispositivo físico/iOS Simulator: usa tu IP local (verifica con ipconfig)
  // - Producción: usa tu dominio real
  
  static const bool _isAndroidEmulator = false; // Cambia a false si usas dispositivo físico
  
  static String get apiUrl {
    if (_isAndroidEmulator) {
      return 'http://10.0.2.2:8000/api/';
    } else {
      return 'http://192.168.1.14:8000/api/'; // Tu IP local
    }
  }
}
