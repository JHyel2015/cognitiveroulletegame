import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BlueApp extends StatefulWidget {
  @override
  _BlueAppState createState() => _BlueAppState();
}

class _BlueAppState extends State<BlueApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristicTX;
  BluetoothCharacteristic? characteristicRX;
  List<BluetoothService> services = [];

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name.isNotEmpty || r.device.name.length != 0) {
          print('${r.device.name} found! rssi: ${r.rssi}');
        }
        // Filtrar dispositivo por nombre
        if (r.device.name.contains('ESP32')) {
          flutterBlue.stopScan();
          connectToDevice(r.device);
          break;
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });

    List<BluetoothService> deviceServices = await device.discoverServices();
    setState(() {
      services = deviceServices;
    });

    for (BluetoothService service in deviceServices) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            '6e400002-b5a3-f393-e0a9-e50e24dcca9e') {
          characteristicRX = characteristic;
        }
        if (characteristic.uuid.toString() ==
            '6e400003-b5a3-f393-e0a9-e50e24dcca9e') {
          characteristicTX = characteristic;
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            print('Received: ${String.fromCharCodes(value)}');
          });
        }
      }
    }
  }

  void sendData(String data) {
    if (characteristicRX != null) {
      characteristicRX!.write(utf8.encode(data));
    }
  }

  void disconnectFromDevice() {
    connectedDevice?.disconnect();
    setState(() {
      connectedDevice = null;
      services = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32 BLE'),
      ),
      body: Center(
        child: connectedDevice == null
            ? Text('Scanning for devices...')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Connected to ${connectedDevice!.name}'),
                  ElevatedButton(
                    onPressed: disconnectFromDevice,
                    child: Text('Disconnect'),
                  ),
                  TextField(
                    onSubmitted: (value) {
                      sendData(value);
                    },
                    decoration: InputDecoration(labelText: 'Send to ESP32'),
                  ),
                ],
              ),
      ),
    );
  }
}
