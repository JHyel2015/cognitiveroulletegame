import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BlueAppTwo extends StatefulWidget {
  @override
  _BlueAppTwoState createState() => _BlueAppTwoState();
}

class _BlueAppTwoState extends State<BlueAppTwo> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  BluetoothCharacteristic? targetCharacteristic;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
          setState(() {
            devicesList.add(r.device);
          });
        }
      }
    });

    flutterBlue.stopScan();
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.disconnect();
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    discoverServices();
  }

  void discoverServices() async {
    if (connectedDevice != null) {
      var discoveredServices = await connectedDevice!.discoverServices();
      setState(() {
        services = discoveredServices;
      });
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            setState(() {
              targetCharacteristic = characteristic;
            });
          }
        }
      }
    }
  }

  void sendData(String data) async {
    if (targetCharacteristic != null) {
      await targetCharacteristic!.write(data.codeUnits);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Communication'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name),
                  subtitle: Text(devicesList[index].id.toString()),
                  onTap: () {
                    connectToDevice(devicesList[index]);
                  },
                );
              },
            ),
          ),
          if (connectedDevice != null) ...[
            TextField(
              onSubmitted: (data) {
                sendData(data);
              },
              decoration: InputDecoration(
                labelText: 'Send Data',
              ),
            ),
          ]
        ],
      ),
    );
  }
}
