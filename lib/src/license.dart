import 'dart:io';

class SoftwareLicense {
  final DateTime issuedTime;
  final DateTime? expiryTime;
  final String licensedTo;
  final List<String> features;
  final String? machineId;

  const SoftwareLicense({
    required this.issuedTime,
    this.expiryTime,
    required this.licensedTo,
    required this.features,
    this.machineId,
  });

  bool hasExpiryTime() {
    return expiryTime != null;
  }

  bool validForTime({DateTime? time}) {
    time ??= DateTime.now();

    if (expiryTime == null) {
      if (issuedTime.isBefore(time)) {
        return true;
      } else {
        return false;
      }
    } else if (issuedTime.isBefore(time) && expiryTime!.isAfter(time)) {
      return true;
    }

    return false;
  }

  bool validForHostName({String? hostName}) {
    hostName ??= Platform.localHostname;

    return (machineId == null) || (machineId! == hostName);
  }

  Map<String, dynamic> toMap() {
    return {
      'issued-time': issuedTime.toIso8601String(),
      'expiry-time': expiryTime?.toIso8601String() ?? '',
      'licensed-to': licensedTo,
      'machine-id': machineId ?? '',
      'features': features
    };
  }

  static SoftwareLicense fromMap(Map<String, dynamic> map) {
    return SoftwareLicense(
      issuedTime: DateTime.parse(map['issued-time']),
      licensedTo: map['licensed-to'],
      features: map['features'].toList().cast<String>(),
      expiryTime: map.containsKey('expiry-time') ? DateTime.tryParse(map['expiry-time']) : null,
      machineId: map.containsKey('machine-id') ? map['machine-id'] : null,
    );
  }
}
