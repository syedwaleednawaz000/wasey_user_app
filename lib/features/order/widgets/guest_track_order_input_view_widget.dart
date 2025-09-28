import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuestTrackOrderInputViewWidget extends StatelessWidget {
  const GuestTrackOrderInputViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'please_login_to_track_orders'.tr,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,  // <-- use bodyLarge instead of bodyText1
      ),
    );
  }
}
