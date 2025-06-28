class DID {
  final String id;
  final String method;
  final String identifier;
  final String controller;
  final DateTime created;
  final DateTime? updated;
  final List<VerificationMethod> verificationMethods;
  final List<String> authentication;
  final Map<String, dynamic> service;
  final bool isActive;

  DID({
    required this.id,
    required this.method,
    required this.identifier,
    required this.controller,
    required this.created,
    this.updated,
    required this.verificationMethods,
    required this.authentication,
    required this.service,
    this.isActive = true,
  });

  String get fullDid => 'did:$method:$identifier';

  factory DID.fromJson(Map<String, dynamic> json) {
    return DID(
      id: json['id'] ?? '',
      method: json['method'] ?? '',
      identifier: json['identifier'] ?? '',
      controller: json['controller'] ?? '',
      created: DateTime.parse(json['created']),
      updated: json['updated'] != null 
          ? DateTime.parse(json['updated'])
          : null,
      verificationMethods: (json['verificationMethods'] as List? ?? [])
          .map((vm) => VerificationMethod.fromJson(vm))
          .toList(),
      authentication: List<String>.from(json['authentication'] ?? []),
      service: json['service'] ?? {},
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'identifier': identifier,
      'controller': controller,
      'created': created.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'verificationMethods': verificationMethods.map((vm) => vm.toJson()).toList(),
      'authentication': authentication,
      'service': service,
      'isActive': isActive,
    };
  }
}

class VerificationMethod {
  final String id;
  final String type;
  final String controller;
  final String publicKeyBase58;

  VerificationMethod({
    required this.id,
    required this.type,
    required this.controller,
    required this.publicKeyBase58,
  });

  factory VerificationMethod.fromJson(Map<String, dynamic> json) {
    return VerificationMethod(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      controller: json['controller'] ?? '',
      publicKeyBase58: json['publicKeyBase58'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'controller': controller,
      'publicKeyBase58': publicKeyBase58,
    };
  }
} 