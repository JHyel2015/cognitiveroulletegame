import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/blue_app_two.dart';
import 'package:cognitiveroulletegame/pages/blue_scan_page.dart';
import 'package:cognitiveroulletegame/pages/bluetooth_app.dart';
import 'package:cognitiveroulletegame/pages/find_devices_screen.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:cognitiveroulletegame/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserPreferences userPreferences = UserPreferences();
  final _timeController = TextEditingController();
  final double _kItemExtent = 32.00;

  final Map<String, int> _timeMap = {
    '15 seg': 15,
    '1 min': 60,
    '5 min': 300,
    '10 min': 600,
    '15 min': 900,
    '20 min': 1200,
    '25 min': 1500,
    '30 min': 1800,
    '35 min': 2100,
    '40 min': 2400,
    '45 min': 2700,
    '50 min': 3000,
    '55 min': 3300,
    '60 min': 3600,
  };

  final List<Widget> _timeList = [
    Center(
      child: Text('15 seg'),
    ),
    Center(
      child: Text('1 min'),
    ),
    Center(
      child: Text('5 min'),
    ),
    Center(
      child: Text('10 min'),
    ),
    Center(
      child: Text('15 min'),
    ),
    Center(
      child: Text('20 min'),
    ),
    Center(
      child: Text('25 min'),
    ),
    Center(
      child: Text('30 min'),
    ),
    Center(
      child: Text('35 min'),
    ),
    Center(
      child: Text('40 min'),
    ),
    Center(
      child: Text('45 min'),
    ),
    Center(
      child: Text('50 min'),
    ),
    Center(
      child: Text('55 min'),
    ),
    Center(
      child: Text('60 min'),
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timeController.text = _timeMap.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Ajustes'),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ListTile(
                  title: Text('Tiempo'),
                  trailing: Text(_timeController.text),
                  onTap: () {
                    showTimePicker(
                      context,
                      _timeController,
                      children: _timeList,
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: ListTile(
                  title: Text('Bluetooth'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          // return FindDevicesScreen();
                          return BlueAppTwo();
                          // return BlueScanPage();
                        },
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showTimePicker(
      BuildContext context, TextEditingController textEditingController,
      {required List<Widget> children}) {
    return showPicker(
      context,
      child: CupertinoPicker(
        magnification: 1.22,
        squeeze: 1.2,
        useMagnifier: true,
        itemExtent: _kItemExtent,
        // This sets the initial item.
        scrollController: FixedExtentScrollController(
          initialItem:
              _timeMap.keys.toList().indexOf(textEditingController.text),
        ),
        // This is called when selected item is changed.
        onSelectedItemChanged: (int selectedItem) {
          setState(() {
            textEditingController.text = _timeMap.keys.toList()[selectedItem];
            userPreferences.time = _timeMap.values.toList()[selectedItem];
          });
        },
        children: children,
      ),
    );
  }
}
