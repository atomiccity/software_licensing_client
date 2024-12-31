import 'package:software_licensing_client/src/license.dart';

abstract class LicenseStorage {
  Future<SoftwareLicense> loadLicense();
  Future<void> storeLicense(String licenseFileData);
}

class LocalLicenseStorage extends LicenseStorage {
  @override
  Future<SoftwareLicense> loadLicense() {
    // TODO: implement loadLicense
    throw UnimplementedError();
  }

  @override
  Future<void> storeLicense(String licenseFileData) {
    // TODO: implement storeLicense
    throw UnimplementedError();
  }
}
