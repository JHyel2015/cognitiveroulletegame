import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();

  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._internal();

  late SharedPreferences _preferences;

  initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  bool get isLogged => _preferences.getBool('isLogged') ?? false;

  set isLogged(bool value) {
    _preferences.setBool('isLogged', value);
  }

  bool get lightTheme => _preferences.getBool('lightTheme') ?? true;

  set lightTheme(bool value) {
    _preferences.setBool('lightTheme', value);
  }

  bool get firstTime => _preferences.getBool('firstTime') ?? true;

  set firstTime(bool value) {
    _preferences.setBool('firstTime', value);
  }

  bool get isMute => _preferences.getBool('isMute') ?? false;

  set isMute(bool value) {
    _preferences.setBool('isMute', value);
  }

  bool get isAnonymous => _preferences.getBool('isAnonymous') ?? false;

  set isAnonymous(bool value) {
    _preferences.setBool('isAnonymous', value);
  }

  bool get isLedOn => _preferences.getBool('isLedOn') ?? false;

  set isLedOn(bool value) {
    _preferences.setBool('isLedOn', value);
  }

  bool get areImagesDownloaded =>
      _preferences.getBool('areImagesDownloaded') ?? false;

  set areImagesDownloaded(bool value) {
    _preferences.setBool('areImagesDownloaded', value);
  }

  int get time => _preferences.getInt('time') ?? 15;

  set time(int value) {
    _preferences.setInt('time', value);
  }

  String get storedUID =>
      _preferences.getString('anonymousUID') ?? 'anonymousUID';

  set storedUID(String value) {
    _preferences.setString('anonymousUID', value);
  }
}
