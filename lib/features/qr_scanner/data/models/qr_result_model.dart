import '../../domain/entities/qr_result.dart';

class QRResultModel extends QRResult {
  const QRResultModel({
    required String rawData,
    required QRDataType type,
    Map<String, dynamic>? parsedData,
    required DateTime scannedAt,
    String? title,
    String? description,
  }) : super(
          rawData: rawData,
          type: type,
          parsedData: parsedData,
          scannedAt: scannedAt,
          title: title,
          description: description,
        );

  factory QRResultModel.fromJson(Map<String, dynamic> json) {
    return QRResultModel(
      rawData: json['rawData'] ?? '',
      type: QRDataType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => QRDataType.unknown,
      ),
      parsedData: json['parsedData'],
      scannedAt: DateTime.parse(json['scannedAt']),
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rawData': rawData,
      'type': type.toString(),
      'parsedData': parsedData,
      'scannedAt': scannedAt.toIso8601String(),
      'title': title,
      'description': description,
    };
  }

  QRResultModel copyWith({
    String? rawData,
    QRDataType? type,
    Map<String, dynamic>? parsedData,
    DateTime? scannedAt,
    String? title,
    String? description,
  }) {
    return QRResultModel(
      rawData: rawData ?? this.rawData,
      type: type ?? this.type,
      parsedData: parsedData ?? this.parsedData,
      scannedAt: scannedAt ?? this.scannedAt,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
} 