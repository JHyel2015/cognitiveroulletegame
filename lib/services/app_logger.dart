import 'package:logger/logger.dart';

class AppLogger {
  // Instancia única del logger
  static final AppLogger _instance = AppLogger._internal();

  // Configuración del Logger
  final Logger _logger = Logger(
    printer: PrettyPrinter(), // Cambiar si necesitas otro formato
    level:
        const bool.fromEnvironment('dart.vm.product') ? Level.off : Level.debug,
  );

  // Constructor privado
  AppLogger._internal();

  // Método para acceder a la instancia única
  factory AppLogger() {
    return _instance;
  }

  // Métodos para exponer las funciones del logger
  void t(String message) => _logger.t(message);
  void d(String message) => _logger.d(message);
  void i(String message) => _logger.i(message);
  void w(String message) => _logger.w(message);
  void e(String message) => _logger.e(message);
}
