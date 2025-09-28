import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/home/widgets/bad_weather_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 🔥 تم إزالة الخلفية هنا
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: null, // لا خلفية - لا صورة - لا تأثير 3D
          child:  Column(
            children: [
              BadWeatherWidget(),
              BannerView(isFeatured: false),
              SizedBox(height: 12),
            ],
          ),
        ),

        const CategoryView(),
        const SpecialOfferView(isFood: true, isShop: false),
        const ItemThatYouLoveView(forShop: false),
        // const MostPopularItemView(isFood: true, isShop: false),
      ],
    );
  }
}
