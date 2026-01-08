import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ModuleSwitcherWidget extends StatelessWidget {
  final Color? iconColor;
  const ModuleSwitcherWidget({super.key, this.iconColor});

  Future<void> _handleModuleSwitch(
    SplashController splashController,
    int moduleIndex,
    int moduleId,
    String moduleName,
  ) async {
    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Switch module - this is a void method that triggers async operations internally
    splashController.switchModule(moduleIndex, false, forceReload: false);

    // Wait a bit for the switch to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // Close loading indicator
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Show success message
    Get.showSnackbar(
      GetSnackBar(
        message: 'switched_to'.trParams({'module': moduleName}),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(Get.context!).primaryColor,
        borderRadius: Dimensions.radiusDefault,
        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (splashController) {
        // Only show if we have both Restaurant and Market modules
        if (splashController.moduleList == null || 
            splashController.moduleList!.length < 2) {
          return const SizedBox();
        }

        // Find Restaurant (ID: 2) and Market (ID: 1) modules
        final restaurantModule = splashController.moduleList!
            .firstWhereOrNull((module) => module.id == 2);
        final marketModule = splashController.moduleList!
            .firstWhereOrNull((module) => module.id == 1);

        // Only show if both modules exist
        if (restaurantModule == null || marketModule == null) {
          return const SizedBox();
        }

        final currentModule = splashController.module;
        final isRestaurant = currentModule?.id == 2;

        return PopupMenuButton<int>(
          offset: const Offset(0, 50),
          icon: Icon(
            Icons.store_outlined,
            color: iconColor ?? Theme.of(context).textTheme.bodyLarge!.color,
            size: 28,
          ),
          tooltip: 'switch_module'.tr,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          itemBuilder: (context) => [
            // Restaurant Option
            PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: isRestaurant 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).textTheme.bodyMedium!.color,
                    size: 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      restaurantModule.moduleName ?? 'Restaurant',
                      style: STCMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isRestaurant
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyMedium!.color,
                        fontWeight: isRestaurant ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (isRestaurant)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                ],
              ),
            ),
            // Market Option
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_basket,
                    color: !isRestaurant 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).textTheme.bodyMedium!.color,
                    size: 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      marketModule.moduleName ?? 'Market',
                      style: STCMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: !isRestaurant
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyMedium!.color,
                        fontWeight: !isRestaurant ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (!isRestaurant)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                ],
              ),
            ),
          ],
          onSelected: (moduleId) {
            // Don't switch if already on the same module
            if (currentModule?.id == moduleId) {
              return;
            }

            // Find the module index
            final moduleIndex = splashController.moduleList!
                .indexWhere((module) => module.id == moduleId);
            
            if (moduleIndex != -1) {
              final moduleName = moduleId == 2 
                  ? restaurantModule.moduleName ?? 'Restaurant'
                  : marketModule.moduleName ?? 'Market';
              
              // Call the async handler
              _handleModuleSwitch(
                splashController,
                moduleIndex,
                moduleId,
                moduleName,
              );
            }
          },
        );
      },
    );
  }
}
