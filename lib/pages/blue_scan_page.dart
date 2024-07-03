import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BlueScanPage extends StatefulWidget {
  @override
  _BlueScanPageState createState() => _BlueScanPageState();
}

class _BlueScanPageState extends State<BlueScanPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scan'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devicesList[index].name),
            subtitle: Text(devicesList[index].id.toString()),
            onTap: () async {
              await devicesList[index].disconnect();
              await devicesList[index].connect();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DeviceScreen(device: devicesList[index]),
              ));
            },
          );
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;

  DeviceScreen({required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Center(
        child: Text('Connected to ${device.name}'),
      ),
    );
  }
}
