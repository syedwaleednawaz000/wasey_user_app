import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class LandingCardWidget extends StatelessWidget {
  final String icon;
  final String? imageBaseUrlType;
  final String title;
  const LandingCardWidget(
      {super.key,
      required this.icon,
      required this.title,
      this.imageBaseUrlType});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).primaryColor.withAlpha((0.05 * 255).toInt()),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomImage(
          image: icon,
          height: 45,
          width: 45,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text(title,
            style: STCRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            textAlign: TextAlign.center),
      ]),
    );
  }
}
