import 'package:equatable/equatable.dart';

enum Description {
  GOLD_FEMALE_SUBCATEGORY,
  GOLD_MENS_SUBCATEGORY;

  factory Description.fromJson(String json) => Description.values
      .firstWhere((e) => e.toString().split('.').last == json);

  String toJson() => toString().split('.').last;
}

enum Gender {
  MEN,
  WOMEN;

  factory Gender.fromJson(String json) =>
      Gender.values.firstWhere((e) => e.toString().split('.').last == json);

  String toJson() => toString().split('.').last;
}

enum Wholeseller {
  BANSAL;

  factory Wholeseller.fromJson(String json) => Wholeseller.values
      .firstWhere((e) => e.toString().split('.').last == json);

  String toJson() => toString().split('.').last;
}

class SubCategory extends Equatable {
  final int subcategoryId;
  final String subcategoryName;
  final int subcategoryCode;
  final int categoryCode;
  final Description description;
  final int price;
  final String exfield1;
  final String? exfield2; // Nullable field
  final Gender gender;
  final int genderCode;
  final DateTime createDate;
  final DateTime modiDate;
  final Wholeseller wholeseller;

  const SubCategory({
    required this.subcategoryId,
    required this.subcategoryName,
    required this.subcategoryCode,
    required this.categoryCode,
    required this.description,
    required this.price,
    required this.exfield1,
    this.exfield2,
    required this.gender,
    required this.genderCode,
    required this.createDate,
    required this.modiDate,
    required this.wholeseller,
  });

  // Factory constructor for JSON deserialization
  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subcategoryId: json['subcategoryId'] ?? 0,
      subcategoryName: json['subcategoryName'] ?? '',
      subcategoryCode: json['subcategoryCode'] ?? 0,
      categoryCode: json['categoryCode'] ?? 0,
      description: Description.fromJson(json['description'] ?? ''),
      price: json['price'] ?? 0,
      exfield1: json['exfield1'] ?? '',
      exfield2: json['exfield2'],
      gender: Gender.fromJson(json['gender'] ?? ''),
      genderCode: json['genderCode'] ?? 0,
      createDate: DateTime.parse(json['createDate']),
      modiDate: DateTime.parse(json['modiDate']),
      wholeseller: Wholeseller.fromJson(json['wholeseller'] ?? ''),
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'subcategoryCode': subcategoryCode,
      'categoryCode': categoryCode,
      'description': description.toJson(),
      'price': price,
      'exfield1': exfield1,
      'exfield2': exfield2,
      'gender': gender.toJson(),
      'genderCode': genderCode,
      'createDate': createDate.toIso8601String(),
      'modiDate': modiDate.toIso8601String(),
      'wholeseller': wholeseller.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        subcategoryId,
        subcategoryName,
        subcategoryCode,
        categoryCode,
        description,
        price,
        exfield1,
        exfield2,
        gender,
        genderCode,
        createDate,
        modiDate,
        wholeseller,
      ];
}
