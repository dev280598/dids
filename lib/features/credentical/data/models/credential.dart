class Credential {
  final String id;
  final String title;
  final String issuer;
  final String issuerLogo;
  final bool isVerified;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final String description;
  final CredentialType type;
  final Map<String, dynamic> data;

  Credential({
    required this.id,
    required this.title,
    required this.issuer,
    required this.issuerLogo,
    required this.isVerified,
    required this.issuedDate,
    this.expiryDate,
    required this.description,
    required this.type,
    required this.data,
  });

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      issuer: json['issuer'] ?? '',
      issuerLogo: json['issuerLogo'] ?? '',
      isVerified: json['isVerified'] ?? false,
      issuedDate: DateTime.parse(json['issuedDate']),
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'])
          : null,
      description: json['description'] ?? '',
      type: CredentialType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CredentialType.other,
      ),
      data: json['data'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'issuer': issuer,
      'issuerLogo': issuerLogo,
      'isVerified': isVerified,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'description': description,
      'type': type.toString(),
      'data': data,
    };
  }
}

enum CredentialType {
  identity,
  license,
  certificate,
  employment,
  education,
  other,
}

extension CredentialTypeExtension on CredentialType {
  String get displayName {
    switch (this) {
      case CredentialType.identity:
        return 'Identity';
      case CredentialType.license:
        return 'License';
      case CredentialType.certificate:
        return 'Certificate';
      case CredentialType.employment:
        return 'Employment';
      case CredentialType.education:
        return 'Education';
      case CredentialType.other:
        return 'Other';
    }
  }
} 