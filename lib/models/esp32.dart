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
  int puntaje;
  String colorSeleccionado;
  String colorQueJuega;
  int indiceColorEncendido;
  int indiceColorSeleccionado;
  int valorEnvioBoton;

  Sensores({
    this.puntaje = 1,
    this.colorSeleccionado = 'Ninguno',
    this.colorQueJuega = 'Violeta',
    this.indiceColorEncendido = -1,
    this.indiceColorSeleccionado = -1,
    this.valorEnvioBoton = 0,
  });

  factory Sensores.fromJson(Map<String, dynamic> json) => Sensores(
        colorSeleccionado: json["colorSeleccionado"],
        colorQueJuega: json["color_que_juega"],
        indiceColorEncendido:
            (int.tryParse(json["indiceColorEncendido"].toString()) ?? 0),
        indiceColorSeleccionado:
            (int.tryParse(json["indiceColorSeleccionado"].toString()) ?? 0),
        puntaje: json["puntaje"],
        valorEnvioBoton:
            (int.tryParse(json["valorEnvioBoton"].toString()) ?? 0),
      );

  Map<String, dynamic> toJson() => {
        "puntaje": puntaje,
        "colorSeleccionado": colorSeleccionado,
        "color_que_juega": colorQueJuega,
        "indiceColorEncendido": indiceColorEncendido,
        "indiceColorSeleccionado": indiceColorSeleccionado,
        "valorEnvioBoton": valorEnvioBoton,
      };
}
