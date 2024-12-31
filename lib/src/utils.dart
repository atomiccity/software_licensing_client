import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

RSAPublicKey pemToRsaPublicKey(String pem) {
  final lines = pem.split('\n').where((line) => line.isNotEmpty && !line.startsWith('---')).toList();
  final b64String = lines.join('');
  final asn1Parser = ASN1Parser(base64.decode(b64String));
  final asn1Sequence = asn1Parser.nextObject() as ASN1Sequence;

  final publicKeyString = asn1Sequence.elements?[1] as ASN1BitString;
  final publicKeyBytes = publicKeyString.stringValues!;
  final publicKeyParser = ASN1Parser(Uint8List.fromList(publicKeyBytes));
  final publicKeySequence = publicKeyParser.nextObject() as ASN1Sequence;

  final modulus = publicKeySequence.elements?[0] as ASN1Integer;
  final exponent = publicKeySequence.elements?[1] as ASN1Integer;

  return RSAPublicKey(_decodeBigInt(modulus.valueBytes!), _decodeBigInt(exponent.valueBytes!));
}

RSAPrivateKey pemToRsaPrivateKey(String pem) {
  final lines = pem.split('\n').where((line) => line.isNotEmpty && !line.startsWith('---')).toList();
  final b64String = lines.join('');
  final asn1Parser = ASN1Parser(base64.decode(b64String));
  final asn1Sequence = asn1Parser.nextObject() as ASN1Sequence;

  final publicKeyString = asn1Sequence.elements?[1] as ASN1BitString;
  final publicKeyBytes = publicKeyString.stringValues!;
  final publicKeyParser = ASN1Parser(Uint8List.fromList(publicKeyBytes));
  final publicKeySequence = publicKeyParser.nextObject() as ASN1Sequence;

  final modulus = publicKeySequence.elements?[0] as ASN1Integer;
  final exponent = publicKeySequence.elements?[1] as ASN1Integer;

  return RSAPrivateKey(_decodeBigInt(modulus.valueBytes!), _decodeBigInt(exponent.valueBytes!));
}

BigInt _decodeBigInt(List<int> bytes) {
  final negative = bytes.isNotEmpty && bytes[0] & 0x80 == 0x80;
  final unsignedBytes = negative ? [0] + bytes : bytes;
  final result = BigInt.parse(unsignedBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(), radix: 16);
  return negative ? result.toUnsigned(8 * bytes.length) : result;
}
