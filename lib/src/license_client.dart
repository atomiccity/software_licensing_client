import 'package:software_licensing_client/src/license.dart';
import 'package:software_licensing_client/src/license_activator.dart';
import 'package:software_licensing_client/src/license_io.dart';
import 'package:software_licensing_client/src/license_storage.dart';

class LicenseClient {
  final String publicKey;
  final LicenseStorage storage;
  final LicenseActivator activator;
  SoftwareLicense? _license;

  LicenseClient({required this.publicKey, required this.storage, required this.activator});

  Future<bool> loadLocalLicense() async {
    _license = await storage.loadLicense();
    return _license != null;
  }

  Future<bool> activateLicense({
    required String key,
    String? username,
    String? machineId,
    required Function(String) onError,
  }) async {
    var response = await activator.activateLicense(
      key: key,
      username: username,
      machineId: machineId,
    );

    if (response.ok && response.licenseFileData != null) {
      // Store the license locally
      storage.storeLicense(response.licenseFileData!);
      // Cache the license in this service
      var licenseReader = SoftwareLicenseIO(publicKey: publicKey);
      _license = licenseReader.read(response.licenseFileData!);
      return true;
    } else {
      onError(response.message);
      return false;
    }
  }

  bool hasFeature(String feature) {
    return (_license != null) &&
        _license!.validForTime() &&
        _license!.validForHostName() &&
        _license!.features.contains(feature);
  }
}
