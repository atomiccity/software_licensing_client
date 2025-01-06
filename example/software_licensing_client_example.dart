import 'package:software_licensing_client/software_licensing_client.dart';

void main() async {
  var licenseClient = KeyedLicenseClient(
      storage: LocalLicenseStorage(),
      activator: WebApiLicenseActivator(host: 'myhost.com', path: '/validate'),
      publicKey: 'Your public key in PEM format');
  var localLicenseExists = await licenseClient.loadLocalLicense();
  if (!localLicenseExists) {
    var successfulActivation = await licenseClient.activateLicense(
        key: 'Serial # given to user',
        onError: (message) {
          // Display error message to user
        },
        onSuccess: () {
          // Display success message to user
        });
  }

  // Later in app
  if (licenseClient.hasFeature('unlockable_feature')) {
    // Enable feature here
  }
}
