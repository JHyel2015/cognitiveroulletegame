import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  Map<Guid, List<int>> readValues = {};

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        // Puedes filtrar el dispositivo por su nombre o ID
        if (r.device.name.contains('MacBook')) {
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
        if (characteristic.properties.read) {
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              readValues[characteristic.uuid] = value;
            });
          });
        }
      }
    }
  }

  void disconnectFromDevice() {
    connectedDevice?.disconnect();
    setState(() {
      connectedDevice = null;
      services = [];
      readValues = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth App'),
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
                  ...services.map((service) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: service.characteristics.map((characteristic) {
                        return ListTile(
                          title: Text('Characteristic ${characteristic.uuid}'),
                          subtitle: Text(
                              readValues[characteristic.uuid]?.toString() ??
                                  'No data'),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
