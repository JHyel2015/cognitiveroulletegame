import 'package:cognitiveroulletegame/pages/device_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return ElevatedButton(
                                    child: Text('OPEN'),
                                    onPressed: () async {
                                      // List<BluetoothService> deviceServices =
                                      //     await d.discoverServices();
                                      // for (BluetoothService service
                                      //     in deviceServices) {
                                      //   for (BluetoothCharacteristic characteristic
                                      //       in service.characteristics) {
                                      //     if (characteristic.properties.read) {
                                      //       await characteristic
                                      //           .setNotifyValue(true);
                                      //       characteristic.value
                                      //           .listen((value) {
                                      //         print(value);
                                      //       });
                                      //     }
                                      //   }
                                      // }
                                      print(d.name);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DeviceScreen(device: d)));
                                    },
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => ListTile(
                          title: Text(r.device.name),
                          subtitle: Text(r.device.toString()),
                          onTap: () {
                            r.device.connect();
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) {
                            //       r.device.connect();
                            //       return DeviceScreen(device: r.device);
                            //     },
                            //   ),
                            // );
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
