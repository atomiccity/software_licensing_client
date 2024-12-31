import 'dart:convert';

import 'package:software_licensing_client/src/license.dart';
import 'package:software_licensing_client/src/utils.dart';
import 'package:pointycastle/export.dart';

class InvalidLicenseFormatException implements Exception {
  final String message;

  const InvalidLicenseFormatException(this.message);
}

class PrivateKeyRequiredError extends Error {
  final String message;

  PrivateKeyRequiredError(this.message);
}

class SoftwareLicenseIO {
  static const licenseFileHeader = '-----BEGIN LICENSE FILE-----';
  static const licenseFileFooter = '------END LICENSE FILE------';

  final String publicKey;
  final String? privateKey;

  const SoftwareLicenseIO({required this.publicKey, this.privateKey});

  SoftwareLicense read(String licenseData) {
    final base64Decoder = utf8.fuse(base64);
    final trimedData = licenseData
        .replaceFirst(licenseFileHeader, '')
        .replaceFirst(licenseFileFooter, '')
        .replaceAll('\r', '')
        .replaceAll('\n', '');

    try {
      final payload = json.decode(base64Decoder.decode(trimedData));
      final softwareLicense = utf8.encode(payload['data']);
      final signature = RSASignature(base64.decode(payload['signature']));
      final algorithm = payload['algorithm'];
      final verifier = Signer(algorithm);

      verifier.init(false, PublicKeyParameter<RSAPublicKey>(pemToRsaPublicKey(publicKey)));
      if (!verifier.verifySignature(softwareLicense, signature)) {
        throw InvalidLicenseFormatException('Digital signature could not be verified');
      }

      final jsonData = json.decode(base64Decoder.decode(payload['data']));
      return SoftwareLicense.fromMap(jsonData);
    } on Exception catch (e) {
      throw InvalidLicenseFormatException('License data not in a valid format: ${e.toString()}');
    }
  }

  String write(SoftwareLicense license) {
    if (privateKey == null) throw PrivateKeyRequiredError('Private key is required to write a software license');

    final softwareLicense = utf8.encode(base64.encode(utf8.encode(json.encode(license.toMap()))));
    final algorithm = "SHA-512/RSA";
    final signer = Signer(algorithm);
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(pemToRsaPrivateKey(privateKey!)));
    final signature = signer.generateSignature(softwareLicense);
    final jsonPacket = json.encode({
      'data': softwareLicense,
      'signature': signature,
      'algorithm': algorithm,
    });

    return '$licenseFileHeader\n${base64.encode(utf8.encode(jsonPacket))}\n$licenseFileFooter';
  }
}
