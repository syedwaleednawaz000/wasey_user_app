import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/address_helper.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../location/domain/models/zone_response_model.dart';
import '../controllers/delivery_working_hours_schedule_controller.dart';

class WorkingHoursBottomSheet extends StatefulWidget {
  const WorkingHoursBottomSheet({Key? key}) : super(key: key);

  @override
  State<WorkingHoursBottomSheet> createState() =>
      _WorkingHoursBottomSheetState();
}

class _WorkingHoursBottomSheetState extends State<WorkingHoursBottomSheet> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TimeSlotController>(
      builder: (controller) {
        if (controller.isLoading) {
          return _buildLoadingSheet();
        }

        if (controller.error != null || controller.timeSlot == null) {
          return _buildErrorSheet(controller.error);
        }

        final slot = controller.timeSlot!;
        // final bool deliveryHoursAvailable = slot.isDeliveryAvailableNow;
        final bool pickupHoursAvailable = slot.isPickupAvailableNow;
        final bool isDeliverySystemEnable = slot.deliverySlotSystemEnabled;
        final bool isPickupSystemEnable = slot.pickupSlotSystemEnabled;
        final String deliverySlotMessage =
            (slot.deliverySlotMessage.isNotEmpty &&
                    slot.deliverySlotMessage != "")
                ? slot.deliverySlotMessage
                : "you_can_pick_up_your_order".tr;

        // Explicitly define the type as nullable (ZoneData?)
        ZoneData? currentZoneData;

        // Get the user's address data
        // final address = AddressHelper.getUserAddressFromSharedPref();

        // Safely check if the address and zoneData exist before searching
        // if (address != null && address.zoneData != null) {
        //
        //   try {
        //     currentZoneData = address.zoneData!.firstWhere(
        //       (data) => data.id == slot. zoneId,
        //     );
        //   } catch (e) {
        //     // firstWhere throws an error if no element is found, so we catch it
        //     // and currentZoneData remains null, which is the desired outcome.
        //   }
        // }

        // Now you can safely get the message if currentZoneData is not null
        // The property seems to be 'deliveryUnavailableMessage' in your model
        // deliverySlotMessage = currentZoneData?.deliverySlotMessage;
        // deliverySlotMessage = address?.zoneData?[1].deliverySlotMessage;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Icon(
                      // isPickupSystemEnable
                      //     ? Icons.access_time
                      //     :
                      Icons.access_time_filled,
                      color: Theme.of(context).primaryColor,
                      // pickupHoursAvailable ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "delivery_currently_unavailable".tr,
                      // isPickupSystemEnable
                      //     ? "openForPickup".tr
                      //     : "pickupTemporarilyClosed".tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      style: IconButton.styleFrom(
                        minimumSize: const Size(20, 20),
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall,
                        ),
                        iconSize: 16,
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  deliverySlotMessage,
                  // !isDeliverySystemEnable && !isPickupSystemEnable
                  //     ? "deliveryTemporarilyClosed".tr
                  //     : !isPickupSystemEnable && isDeliverySystemEnable
                  //         ? "deliveryAvailableNow".tr
                  //         : "deliveryNotAvailable".tr,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              //working hours section starts from here
              // TextButton.icon(
              //   onPressed: () => setState(() => _isExpanded = !_isExpanded),
              //   icon: Icon(
              //     _isExpanded
              //         ? Icons.keyboard_arrow_up
              //         : Icons.keyboard_arrow_down,
              //   ),
              //   label: Text(
              //     _isExpanded ? "hideWorkingHours".tr : "showWorkingHours".tr,
              //   ),
              // ),
              // if (_isExpanded)
              //   Container(
              //     width: double.infinity,
              //     color: Colors.black54,
              //     padding: const EdgeInsets.all(16),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         _buildHoursSection("${"deliveryHours".tr}",
              //             slot.weeklyDeliveryTimeSlots, 'delivery'),
              //         const SizedBox(height: 16),
              //         _buildHoursSection("pickupHours".tr,
              //             slot.weeklyPickupTimeSlots, 'pickup'),
              //       ],
              //     ),
              //   ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHoursSection(
      String title, Map<String, List<String>?> slots, String type) {
    final daysOrder = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              type == 'pickup' ? Icons.directions_walk : Icons.delivery_dining,
              color: Colors.white,
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...daysOrder.map((dayKey) {
          final times = slots[dayKey];
          final dayNameTr = dayKey.tr;

          if (times == null) {
            return _dayRow(dayNameTr, "closed".tr, isClosed: true);
          }

          final timeStr = times.join(' - ');
          return _dayRow(dayNameTr, timeStr, isClosed: false);
        }),
      ],
    );
  }

  Widget _dayRow(String day, String time, {required bool isClosed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: STCRegular.copyWith(color: Colors.white),
          ),
          Text(
            time,
            style: STCMedium.copyWith(
              color: isClosed ? Colors.red : Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSheet() => Container(
        height: 150,
        decoration: const BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child:
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

  Widget _buildErrorSheet(String? error) => Container(
        height: 150,
        decoration: const BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              20,
            ),
          ),
        ),
        child: Center(
          child: Text(
            error ?? "unknownError".tr,
            style: const TextStyle(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}
