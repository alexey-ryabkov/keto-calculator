import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<bool> isRunningOnEmulator() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return !info.isPhysicalDevice;
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return !info.isPhysicalDevice;
  }
  return false;
}
