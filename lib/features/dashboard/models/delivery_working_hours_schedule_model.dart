class TimeSlotResponse {
  final List<ZoneTimeSlot> data;
  final String currentTime;
  final String currentDay;

  TimeSlotResponse({
    required this.data,
    required this.currentTime,
    required this.currentDay,
  });
  factory TimeSlotResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return TimeSlotResponse(
      data: dataList
          .map((e) => ZoneTimeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentTime: json['current_time']?.toString() ?? '',
      currentDay: json['current_day']?.toString() ?? '',
    );
  }
  // factory TimeSlotResponse.fromJson(Map<String, dynamic> json) {
  //   return TimeSlotResponse(
  //     data: (json['data'] as List)
  //         .map((e) => ZoneTimeSlot.fromJson(e as Map<String, dynamic>))
  //         .toList(),
  //     currentTime: json['current_time']?.toString() ?? '',
  //     currentDay: json['current_day']?.toString() ?? '',
  //   );
  // }
}

class ZoneTimeSlot {
  final int zoneId;
  final String zoneName;
  final String deliverySlotMessage;
  final String currentDay;
  final bool pickupSlotSystemEnabled;
  final bool deliverySlotSystemEnabled;
  final List<String> pickupTimeSlot;
  final List<String> deliveryTimeSlot;
  final bool isPickupAvailableNow;
  final bool isDeliveryAvailableNow;
  final Map<String, List<String>?> weeklyPickupTimeSlots;
  final Map<String, List<String>?> weeklyDeliveryTimeSlots;

  ZoneTimeSlot({
    required this.zoneId,
    required this.zoneName,
    required this.deliverySlotMessage,
    required this.currentDay,
    required this.pickupSlotSystemEnabled,
    required this.deliverySlotSystemEnabled,
    required this.pickupTimeSlot,
    required this.deliveryTimeSlot,
    required this.isPickupAvailableNow,
    required this.isDeliveryAvailableNow,
    required this.weeklyPickupTimeSlots,
    required this.weeklyDeliveryTimeSlots,
  });

  factory ZoneTimeSlot.fromJson(Map<String, dynamic> json) {
    return ZoneTimeSlot(
      zoneId: json['zone_id'] as int,
      zoneName: json['zone_name']?.toString() ?? '',
      deliverySlotMessage: json['delivery_slot_message']?.toString() ?? '',
      currentDay: json['current_day']?.toString() ?? '',
      pickupSlotSystemEnabled: json['pickup_slot_system_enabled'] == true,
      deliverySlotSystemEnabled: json['delivery_slot_system_enabled'] == true,
      pickupTimeSlot: _toStringList(json['pickup_time_slot']),
      deliveryTimeSlot: _toStringList(json['delivery_time_slot']),
      isPickupAvailableNow: json['is_pickup_available_now'] == true,
      isDeliveryAvailableNow: json['is_delivery_available_now'] == true,
      weeklyPickupTimeSlots: _parseWeeklySlots(json['weekly_pickup_time_slots']),
      weeklyDeliveryTimeSlots: _parseWeeklySlots(json['weekly_delivery_time_slots']),
    );
  }

  // Helper: Convert [dynamic] → List<String>
  static List<String> _toStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Helper: Parse weekly slots with null safety
  static Map<String, List<String>?> _parseWeeklySlots(dynamic data) {
    if (data == null || data is! Map) return {};

    return data.map<String, List<String>?>((key, value) {
      if (value == null) {
        return MapEntry(key.toString(), null);
      }
      if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((e) => e.toString()).toList(),
        );
      }
      return MapEntry(key.toString(), null);
    });
  }
}

//
// class TimeSlotResponse {
//   final List<ZoneTimeSlot> data;
//   final String currentTime;
//   final String currentDay;
//
//   TimeSlotResponse({required this.data, required this.currentTime, required this.currentDay});
//
//   factory TimeSlotResponse.fromJson(Map<String, dynamic> json) {
//     return TimeSlotResponse(
//       data: (json['data'] as List).map((e) => ZoneTimeSlot.fromJson(e)).toList(),
//       currentTime: json['current_time'] ?? '',
//       currentDay: json['current_day'] ?? '',
//     );
//   }
// }
//
// class ZoneTimeSlot {
//   final int zoneId;
//   final String zoneName;
//   final String currentDay;
//   final bool pickupSlotSystemEnabled;
//   final bool deliverySlotSystemEnabled;
//   final List<String> pickupTimeSlot;
//   final List<String> deliveryTimeSlot;
//   final bool isPickupAvailableNow;
//   final bool isDeliveryAvailableNow;
//   final Map<String, List<String>?> weeklyPickupTimeSlots;
//   final Map<String, List<String>?> weeklyDeliveryTimeSlots;
//
//   ZoneTimeSlot({
//     required this.zoneId,
//     required this.zoneName,
//     required this.currentDay,
//     required this.pickupSlotSystemEnabled,
//     required this.deliverySlotSystemEnabled,
//     required this.pickupTimeSlot,
//     required this.deliveryTimeSlot,
//     required this.isPickupAvailableNow,
//     required this.isDeliveryAvailableNow,
//     required this.weeklyPickupTimeSlots,
//     required this.weeklyDeliveryTimeSlots,
//   });
//
//   factory ZoneTimeSlot.fromJson(Map<String, dynamic> json) {
//     return ZoneTimeSlot(
//       zoneId: json['zone_id'],
//       zoneName: json['zone_name'],
//       currentDay: json['current_day'],
//       pickupSlotSystemEnabled: json['pickup_slot_system_enabled'] == true,
//       deliverySlotSystemEnabled: json['delivery_slot_system_enabled'] == true,
//       pickupTimeSlot: List<String>.from(json['pickup_time_slot'] ?? []),
//       deliveryTimeSlot: List<String>.from(json['delivery_time_slot'] ?? []),
//       isPickupAvailableNow: json['is_pickup_available_now'] == true,
//       isDeliveryAvailableNow: json['is_delivery_available_now'] == true,
//       weeklyPickupTimeSlots: _parseWeeklySlots(json['weekly_pickup_time_slots']),
//       weeklyDeliveryTimeSlots: _parseWeeklySlots(json['weekly_delivery_time_slots']),
//     );
//   }
//
//   static Map<String, List<String>?> _parseWeeklySlots(dynamic data) {
//     if (data == null) return {};
//     return Map<String, List<String>?>.from(data).map((key, value) {
//       return MapEntry(
//         key,
//         value == null ? null : List<String>.from(value),
//       );
//     });
//   }
// }