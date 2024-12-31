import 'package:http/http.dart' as http;

class LicenseActivatorResponse {
  final bool ok;
  final String? licenseFileData;
  final String message;

  const LicenseActivatorResponse({required this.ok, required this.message, this.licenseFileData});
}

abstract class LicenseActivator {
  Future<LicenseActivatorResponse> activateLicense({
    required String key,
    String? username,
    String? machineId,
  });
}

class WebApiLicenseActivator extends LicenseActivator {
  final String host;
  final String path;

  WebApiLicenseActivator({required this.host, required this.path});

  @override
  Future<LicenseActivatorResponse> activateLicense({required String key, String? username, String? machineId}) async {
    var uri = Uri.https(host, path, {
      'key': key,
      if (username != null) 'username': username,
      if (machineId != null) 'machineId': machineId,
    });
    var resp = await http.get(uri);

    if (resp.statusCode == 200) {
      return LicenseActivatorResponse(ok: true, message: 'Success', licenseFileData: resp.body);
    } else if (resp.statusCode == 403) {
      return LicenseActivatorResponse(ok: false, message: 'Invalid license key');
    } else {
      return LicenseActivatorResponse(ok: false, message: 'Server error ${resp.statusCode}');
    }
  }
}
