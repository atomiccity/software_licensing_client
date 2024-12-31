import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:software_licensing_client/software_licensing_client.dart';

import 'package:path/path.dart' as p;

abstract class LicenseStorage {
  Future<SoftwareLicense?> loadLicense(String publicKey);
  Future<void> storeLicense(String licenseFileData);
}

class LocalLicenseStorage extends LicenseStorage {
  static const _licenseName = 'software.lic';

  @override
  Future<SoftwareLicense?> loadLicense(String publicKey) async {
    var appDirKeyPath = p.join(p.dirname(Platform.resolvedExecutable), _licenseName);
    var appSupportDirKeyPath = p.join((await getApplicationSupportDirectory()).path, _licenseName);
    File? keyFile;

    if (File(appDirKeyPath).existsSync()) {
      keyFile = File(appDirKeyPath);
    } else if (File(appSupportDirKeyPath).existsSync()) {
      keyFile = File(appSupportDirKeyPath);
    }

    if (keyFile != null) {
      var licenseIo = SoftwareLicenseIO(publicKey: publicKey);
      return licenseIo.read(await keyFile.readAsString());
    }

    return null;
  }

  @override
  Future<void> storeLicense(String licenseFileData) async {
    var licensePath = p.join((await getApplicationSupportDirectory()).path, _licenseName);
    var licenseFile = File(licensePath);
    await licenseFile.writeAsString(licenseFileData);
  }
}
