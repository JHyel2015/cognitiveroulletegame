import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/services/image_cache_service.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:cognitiveroulletegame/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserPreferences userPreferences = UserPreferences();
  final _timeController = TextEditingController();
  final SpeakerService speakerService = SpeakerService();
  final double _kItemExtent = 32.00;
  bool _isDownloading = false;

  final String _textToSpeak =
      'En esta pantalla se puede ajustar el tiempo de juego y descargar los recursos.';

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
    const Center(
      child: Text('15 seg'),
    ),
    const Center(
      child: Text('1 min'),
    ),
    const Center(
      child: Text('5 min'),
    ),
    const Center(
      child: Text('10 min'),
    ),
    const Center(
      child: Text('15 min'),
    ),
    const Center(
      child: Text('20 min'),
    ),
    const Center(
      child: Text('25 min'),
    ),
    const Center(
      child: Text('30 min'),
    ),
    const Center(
      child: Text('35 min'),
    ),
    const Center(
      child: Text('40 min'),
    ),
    const Center(
      child: Text('45 min'),
    ),
    const Center(
      child: Text('50 min'),
    ),
    const Center(
      child: Text('55 min'),
    ),
    const Center(
      child: Text('60 min'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _speak();
    _timeController.text = _timeMap.keys
        .toList()[_timeMap.values.toList().indexOf(userPreferences.time)];
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  Future<void> _speak({textToSpeak}) async {
    await speakerService.stop();
    await speakerService.speak(textToSpeak ?? _textToSpeak);
  }

  Future _stop() async {
    await speakerService.stop();
    // setState(() => ttsState = TtsState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final savedImageNotifier = Provider.of<ImageCacheService>(
      context,
    );

    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text('Ajustes'),
          ),
          body: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ListTile(
                      title: const Text('Tiempo'),
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
                  if (_isDownloading)
                    SliverToBoxAdapter(
                      child: ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Descargando archivos..."),
                            const SizedBox(height: 20),
                            ValueListenableBuilder<double>(
                              valueListenable:
                                  savedImageNotifier.progressNotifier,
                              builder: (context, progress, child) {
                                return LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8.0,
                                  backgroundColor: Colors.grey.shade300,
                                  color: Colors.blue,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isDownloading = true;
                              });
                              // Puedes reiniciar la descarga
                              savedImageNotifier.getFiles();
                            },
                            child: const Text("Actualizar contenido"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: InkWell(
                  onTap: _speak,
                  child: Hero(
                    tag: 'robot',
                    child: Image.asset(
                      'assets/robot.gif',
                      width: width * .40,
                    ),
                  ),
                ),
              ),
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
