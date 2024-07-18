import 'package:meta/meta.dart';
import 'dart:convert';

Esp32 esp32FromJson(String str) => Esp32.fromJson(json.decode(str));

String esp32ToJson(Esp32 data) => json.encode(data.toJson());

class Esp32 {
  bool estadoLed;
  Esp32DataBase esp32DataBase;

  Esp32({
    required this.estadoLed,
    required this.esp32DataBase,
  });

  factory Esp32.fromJson(Map<String, dynamic> json) => Esp32(
        estadoLed: json["EstadoLED"],
        esp32DataBase: Esp32DataBase.fromJson(json["esp32DataBase"]),
      );

  Map<String, dynamic> toJson() => {
        "EstadoLED": estadoLed,
        "esp32DataBase": esp32DataBase.toJson(),
      };
}

class Esp32DataBase {
  Sensores sensores;

  Esp32DataBase({
    required this.sensores,
  });

  factory Esp32DataBase.fromJson(Map<String, dynamic> json) => Esp32DataBase(
        sensores: Sensores.fromJson(json["Sensores"]),
      );

  Map<String, dynamic> toJson() => {
        "Sensores": sensores.toJson(),
      };
}

class Sensores {
  bool yellow;
  bool blue;
  String colorquEjuega;
  bool orange;
  bool red;
  bool green;
  bool purple;
  int colorJuega;
  int valorEnvio;

  Sensores({
    this.yellow = false,
    this.blue = false,
    this.colorquEjuega = 'Amarillo',
    this.orange = false,
    this.red = false,
    this.green = false,
    this.purple = false,
    this.colorJuega = -1,
    this.valorEnvio = 0,
  });

  factory Sensores.fromJson(Map<String, dynamic> json) => Sensores(
        yellow: json["Amarillo"],
        blue: json["Azul"],
        colorquEjuega: json["COLORQUEjuega"],
        orange: json["Naranja"],
        red: json["Rojo"],
        green: json["Verde"],
        purple: json["Violeta"],
        colorJuega: json["colorJuega"],
        valorEnvio: json["valorEnvio"],
      );

  Map<String, dynamic> toJson() => {
        "Amarillo": yellow,
        "Azul": blue,
        "COLORQUEjuega": colorquEjuega,
        "Naranja": orange,
        "Rojo": red,
        "Verde": green,
        "Violeta": purple,
        "colorJuega": colorJuega,
        "valorEnvio": valorEnvio,
      };
}
