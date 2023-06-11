import 'dart:developer' as dev;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

late String localPath;

Future<void> prepareSaveDir() async {
  localPath = (await findLocalPath())!;
  final savedDir = Directory(localPath);
  bool hasExisted = await savedDir.exists();
  if (!hasExisted) {
    savedDir.create();
  }
  return;
}

Future<String?> findLocalPath() async {
  var externalStorageDirPath;
  if (Platform.isAndroid) {
    try {
      externalStorageDirPath = await getDownloadsDirectory();
      dev.log('getDownloadsDirectory');
    } catch (e) {
      final directory = await getExternalStorageDirectory();
      externalStorageDirPath = directory?.path;
      dev.log('getExternalStorageDirectory: catch');
    }
  } else if (Platform.isIOS) {
    externalStorageDirPath =
        (await getApplicationDocumentsDirectory()).absolute.path;
  }
  return externalStorageDirPath;
}

Future<bool> checkPermissionOpen() async {
  if (Platform.isIOS) return true;

  final status = await Permission.storage.request();
  dev.log('checkPermissionOpen: ${status.toString()}');
  if (status.isGranted) {
    return true;
  } else {
    final android = await DeviceInfoPlugin().androidInfo;
    if (android.version.sdkInt >= 28) {
      dev.log('checkPermissionOpen: sdk ${android.version.sdkInt}');
      return true;
    }
    // if (status == PermissionStatus.permanentlyDenied) {
    //   await openAppSettings();
    //   final status1 = await Permission.storage.status;
    //   return status1.isGranted;
    // }
    Fluttertoast.showToast(msg: 'Permission Required');
    return false;
  }
}
