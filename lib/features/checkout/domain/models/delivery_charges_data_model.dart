import 'dart:convert';

// Main response model
class DeliveryChargesResponse {
  final bool success;
  final List<DeliveryChargeData> data;
  final List<CityWiseChargeStatus> cityWiseChargeEnabled; // New field

  DeliveryChargesResponse({
    required this.success,
    required this.data,
    required this.cityWiseChargeEnabled,
  });

  factory DeliveryChargesResponse.fromRawJson(String str) =>
      DeliveryChargesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DeliveryChargesResponse.fromJson(Map<String, dynamic> json) =>
      DeliveryChargesResponse(
        success: json["success"] ?? false,
        data: json["data"] == null
            ? []
            : List<DeliveryChargeData>.from(
            json["data"].map((x) => DeliveryChargeData.fromJson(x))),
        cityWiseChargeEnabled: json["city_wise_charge_enabled"] == null // New field parsing
            ? []
            : List<CityWiseChargeStatus>.from(
            json["city_wise_charge_enabled"].map((x) => CityWiseChargeStatus.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "city_wise_charge_enabled": List<dynamic>.from(cityWiseChargeEnabled.map((x) => x.toJson())), // New field serialization
  };
}

// Model for individual delivery charge items in the 'data' list
class DeliveryChargeData {
  final int id;
  final int zoneId;
  final int moduleId;
  final String city;
  final int deliveryChargesMin;
  final int deliveryChargesMax;
  final String? createdAt; // New nullable field

  DeliveryChargeData({
    required this.id,
    required this.zoneId,
    required this.moduleId,
    required this.city,
    required this.deliveryChargesMin,
    required this.deliveryChargesMax,
    this.createdAt,
  });

  factory DeliveryChargeData.fromRawJson(String str) =>
      DeliveryChargeData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DeliveryChargeData.fromJson(Map<String, dynamic> json) =>
      DeliveryChargeData(
        id: json["id"] ?? 0,
        zoneId: json["zone_id"] ?? 0,
        moduleId: json["module_id"] ?? 0,
        city: json["city"] ?? "",
        deliveryChargesMin: json["delivery_charges_min"] ?? 0,
        deliveryChargesMax: json["delivery_charges_max"] ?? 0,
        createdAt: json["created_at"], // New field parsing
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "zone_id": zoneId,
    "module_id": moduleId,
    "city": city,
    "delivery_charges_min": deliveryChargesMin,
    "delivery_charges_max": deliveryChargesMax,
    "created_at": createdAt, // New field serialization
  };
}

// New model for the 'city_wise_charge_enabled' list
class CityWiseChargeStatus {
  final int zoneId;
  final int moduleId;
  final bool status;

  CityWiseChargeStatus({
    required this.zoneId,
    required this.moduleId,
    required this.status,
  });

  factory CityWiseChargeStatus.fromRawJson(String str) =>
      CityWiseChargeStatus.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CityWiseChargeStatus.fromJson(Map<String, dynamic> json) =>
      CityWiseChargeStatus(
        zoneId: json["zone_id"] ?? 0,
        moduleId: json["module_id"] ?? 0,
        status: json["status"] ?? false,
      );

  Map<String, dynamic> toJson() => {
    "zone_id": zoneId,
    "module_id": moduleId,
    "status": status,
  };
}


// import 'dart:convert';
//
// // Main response model
// class DeliveryChargesResponse {
//   final bool success;
//   final List<DeliveryChargeData> data;
//
//   DeliveryChargesResponse({
//     required this.success,
//     required this.data,
//   });
//
//   factory DeliveryChargesResponse.fromRawJson(String str) =>
//       DeliveryChargesResponse.fromJson(json.decode(str));
//
//   String toRawJson() => json.encode(toJson());
//
//   factory DeliveryChargesResponse.fromJson(Map<String, dynamic> json) =>
//       DeliveryChargesResponse(
//         success: json["success"] ?? false, // Provide a default if null
//         data: json["data"] == null
//             ? []
//             : List<DeliveryChargeData>.from(
//             json["data"].map((x) => DeliveryChargeData.fromJson(x))),
//       );
//
//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   };
// }
//
// // Model for individual delivery charge items
// class DeliveryChargeData {
//   final int id;
//   final int zoneId;
//   final int moduleId;
//   final String city;
//   final int deliveryChargesMin; // Assuming these are integers, adjust if they can be double
//   final int deliveryChargesMax; // Assuming these are integers, adjust if they can be double
//
//   DeliveryChargeData({
//     required this.id,
//     required this.zoneId,
//     required this.moduleId,
//     required this.city,
//     required this.deliveryChargesMin,
//     required this.deliveryChargesMax,
//   });
//
//   factory DeliveryChargeData.fromRawJson(String str) =>
//       DeliveryChargeData.fromJson(json.decode(str));
//
//   String toRawJson() => json.encode(toJson());
//
//   factory DeliveryChargeData.fromJson(Map<String, dynamic> json) =>
//       DeliveryChargeData(
//         id: json["id"] ?? 0, // Provide defaults
//         zoneId: json["zone_id"] ?? 0,
//         moduleId: json["module_id"] ?? 0,
//         city: json["city"] ?? "",
//         deliveryChargesMin: json["delivery_charges_min"] ?? 0,
//         deliveryChargesMax: json["delivery_charges_max"] ?? 0,
//       );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "zone_id": zoneId,
//     "module_id": moduleId,
//     "city": city,
//     "delivery_charges_min": deliveryChargesMin,
//     "delivery_charges_max": deliveryChargesMax,
//   };
// }
