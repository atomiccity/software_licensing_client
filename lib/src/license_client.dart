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

  /// Attempt to load a locally stored software license.
  ///
  /// Returns `true` if a license exists locally, `false` otherwise
  Future<bool> loadLocalLicense() async {
    _license = await storage.loadLicense(publicKey);
    return _license != null;
  }

  /// Attempt to activate a license key and retrieve a license from a remote server
  ///
  /// Returns `true` if the key was valid and a license could be downloaded,
  /// `false` otherwise
  Future<bool> activateLicense({
    required String key,
    String? username,
    String? machineId,
    required Function onSuccess,
    required Function(String message) onError,
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
      onSuccess();
      return true;
    } else {
      onError(response.message);
      return false;
    }
  }

  /// Returns the user the software is licensed to, if available
  String? licensedTo() {
    return _license?.licensedTo;
  }

  /// Returns `true` if the software license is available and valid
  bool hasValidLicense() {
    return (_license != null) && _license!.validForHostName() && _license!.validForTime();
  }

  /// Checks to see if a feature has been licensed to use
  bool hasFeature(String feature) {
    return (_license != null) &&
        _license!.validForTime() &&
        _license!.validForHostName() &&
        _license!.features.contains(feature);
  }
}
