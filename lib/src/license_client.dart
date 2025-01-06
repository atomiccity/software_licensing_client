import 'package:software_licensing_client/src/license.dart';
import 'package:software_licensing_client/src/license_activator.dart';
import 'package:software_licensing_client/src/license_io.dart';
import 'package:software_licensing_client/src/license_storage.dart';

abstract class LicenseClient {
  Future<bool> loadLocalLicense();
  Future<bool> activateLicense({
    required String key,
    String? username,
    String? machineId,
    required Function onSuccess,
    required Function(String message) onError,
  });
  String? licensedTo();
  bool hasValidLicense();
  bool hasFeature(String feature);

  const LicenseClient();
}

class UnlockedLicenseClient extends LicenseClient {
  final String? licensedUserName;

  const UnlockedLicenseClient({this.licensedUserName});

  @override
  Future<bool> activateLicense({
    required String key,
    String? username,
    String? machineId,
    required Function onSuccess,
    required Function(String message) onError,
  }) async {
    return true;
  }

  @override
  bool hasFeature(String feature) {
    return true;
  }

  @override
  bool hasValidLicense() {
    return true;
  }

  @override
  String? licensedTo() {
    return licensedUserName;
  }

  @override
  Future<bool> loadLocalLicense() async {
    return true;
  }
}

class KeyedLicenseClient extends LicenseClient {
  final String publicKey;
  final LicenseStorage storage;
  final LicenseActivator activator;
  SoftwareLicense? _license;

  KeyedLicenseClient({required this.publicKey, required this.storage, required this.activator});

  /// Attempt to load a locally stored software license.
  ///
  /// Returns `true` if a license exists locally, `false` otherwise
  @override
  Future<bool> loadLocalLicense() async {
    _license = await storage.loadLicense(publicKey);
    return _license != null;
  }

  /// Attempt to activate a license key and retrieve a license from a remote server
  ///
  /// Returns `true` if the key was valid and a license could be downloaded,
  /// `false` otherwise
  @override
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
  @override
  String? licensedTo() {
    return _license?.licensedTo;
  }

  /// Returns `true` if the software license is available and valid
  @override
  bool hasValidLicense() {
    return (_license != null) && _license!.validForHostName() && _license!.validForTime();
  }

  /// Checks to see if a feature has been licensed to use
  @override
  bool hasFeature(String feature) {
    return (_license != null) &&
        _license!.validForTime() &&
        _license!.validForHostName() &&
        _license!.features.contains(feature);
  }
}
