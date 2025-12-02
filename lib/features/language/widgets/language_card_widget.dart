import 'package:flutter/material.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/domain/models/language_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class LanguageCardWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  final bool fromBottomSheet;
  final bool fromWeb;

  const LanguageCardWidget(
      {super.key,
      required this.languageModel,
      required this.localizationController,
      required this.index,
      this.fromBottomSheet = false,
      this.fromWeb = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (fromBottomSheet) {
          localizationController.setLanguage(
              Locale(
                AppConstants.languages[index].languageCode!,
                AppConstants.languages[index].countryCode,
              ),
              fromBottomSheet: fromBottomSheet);
        }
        localizationController.setSelectLanguageIndex(index);
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: !fromWeb
            ? BoxDecoration(
                color: localizationController.selectedLanguageIndex == index
                    ? Theme.of(context)
                        .primaryColor
                        .withAlpha((0.2 * 255).toInt())
                    : Theme.of(context)
                        .disabledColor
                        .withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: localizationController.selectedLanguageIndex == index
                    ? Border.all(
                        color: Theme.of(context)
                            .primaryColor
                            .withAlpha((0.2 * 255).toInt()))
                    :Border.all(
                    color: Theme.of(context)
                        .disabledColor
                        .withAlpha((0.1 * 255).toInt())),
              )
            : BoxDecoration(
                color: localizationController.selectedLanguageIndex == index
                    ? Theme.of(context)
                        .primaryColor
                        .withAlpha((0.05 * 255).toInt())
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(
                    color: localizationController.selectedLanguageIndex == index
                        ? Theme.of(context)
                            .primaryColor
                            .withAlpha((0.2 * 255).toInt())
                        : Theme.of(context)
                            .disabledColor
                            .withAlpha((0.3 * 255).toInt())),
              ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image.asset(languageModel.imageUrl!, width: 36, height: 36),
              // const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(languageModel.languageName!,
                  style: STCRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  )),
              const Spacer(),
              localizationController.selectedLanguageIndex == index
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    )
                  : Icon(
                Icons.circle_outlined,
                color: Theme.of(context)
                    .disabledColor
                    .withAlpha((0.4 * 255).toInt()),
                size: 25,
              ),
            ]),
      ),
    );
  }
}
