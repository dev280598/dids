import 'package:equatable/equatable.dart';

enum QRDataType {
  credential,
  did,
  url,
  text,
  unknown,
}

class QRResult extends Equatable {
  final String rawData;
  final QRDataType type;
  final Map<String, dynamic>? parsedData;
  final DateTime scannedAt;
  final String? title;
  final String? description;

  const QRResult({
    required this.rawData,
    required this.type,
    this.parsedData,
    required this.scannedAt,
    this.title,
    this.description,
  });

  @override
  List<Object?> get props => [
    rawData,
    type,
    parsedData,
    scannedAt,
    title,
    description,
  ];

  QRResult copyWith({
    String? rawData,
    QRDataType? type,
    Map<String, dynamic>? parsedData,
    DateTime? scannedAt,
    String? title,
    String? description,
  }) {
    return QRResult(
      rawData: rawData ?? this.rawData,
      type: type ?? this.type,
      parsedData: parsedData ?? this.parsedData,
      scannedAt: scannedAt ?? this.scannedAt,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
} 