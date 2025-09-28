import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';

class ItemModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Item>? items;
  List<Categories>? categories;

  ItemModel(
      {this.totalSize, this.limit, this.offset, this.items, this.categories});

  ItemModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset =
        (json['offset'] != null && json['offset'].toString().trim().isNotEmpty)
            ? int.parse(json['offset'].toString())
            : null;
    if (json['products'] != null) {
      items = [];
      json['products'].forEach((v) {
        items!.add(Item.fromJson(v));
        // if (v['module_type'] == null ||
        //     !Get.find<SplashController>().getModuleConfig(v['module_type']).newVariation! ||
        //     v['variations'] == null ||
        //     v['variations'].isEmpty ||
        //     (v['food_variations'] != null && v['food_variations'].isNotEmpty)) {
        //   items!.add(Item.fromJson(v));
        // }
      });
    }
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        if (v['module_type'] == null ||
            !Get.find<SplashController>()
                .getModuleConfig(v['module_type'])
                .newVariation! ||
            v['variations'] == null ||
            v['variations'].isEmpty ||
            (v['food_variations'] != null && v['food_variations'].isNotEmpty)) {
          items!.add(Item.fromJson(v));
        }
      });
    }
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (items != null) {
      data['products'] = items!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Item {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  List<String>? imagesFullUrl;
  int? categoryId;
  List<CategoryIds>? categoryIds;
  List<Variation>? variations;
  List<FoodVariation>? foodVariations;
  List<AddOns>? addOns;
  List<ChoiceOptions>? choiceOptions;
  double? price;
  double? tax;
  dynamic discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? storeId;
  String? storeName;
  int? zoneId;
  dynamic storeDiscount;
  bool? scheduleOrder;
  double? avgRating;
  int? ratingCount;
  int? veg;
  int? moduleId;
  String? moduleType;
  String? unitType;
  int? stock;
  String? availableDateStarts;
  int? organic;
  int? quantityLimit;
  int? flashSale;
  bool? isStoreHalalActive;
  bool? isHalalItem;
  bool? isPrescriptionRequired;
  List<String>? nutritionsName;
  List<String>? allergiesName;
  List<String>? genericName;

  Item({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.imagesFullUrl,
    this.categoryId,
    this.categoryIds,
    this.variations,
    this.foodVariations,
    this.addOns,
    this.choiceOptions,
    this.price,
    this.tax,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.storeId,
    this.storeName,
    this.zoneId,
    this.storeDiscount,
    this.scheduleOrder,
    this.avgRating,
    this.ratingCount,
    this.veg,
    this.moduleId,
    this.moduleType,
    this.unitType,
    this.stock,
    this.organic,
    this.quantityLimit,
    this.flashSale,
    this.isStoreHalalActive,
    this.isHalalItem,
    this.isPrescriptionRequired,
    this.nutritionsName,
    this.allergiesName,
    this.genericName,
  });

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    description = json['description'] ?? '';
    imageFullUrl = json['image_full_url'] ?? '';

    imagesFullUrl = (json['images_full_url'] != null)
        ? List<String>.from(
            json['images_full_url'].map((v) => v?.toString() ?? ''))
        : [];

    categoryId = json['category_id'] ?? 0;

    categoryIds = (json['category_ids'] != null)
        ? List<CategoryIds>.from(
            json['category_ids'].map((v) => CategoryIds.fromJson(v)))
        : [];

    variations = (json['variations'] != null)
        ? List<Variation>.from(
            json['variations'].map((v) => Variation.fromJson(v)))
        : [];

    foodVariations = (json['food_variations'] != null)
        ? List<FoodVariation>.from(
            json['food_variations'].map((v) => FoodVariation.fromJson(v)))
        : [];

    // addOns = (json['add_ons'] != null)
    //     ? List<AddOns>.from(json['add_ons'].map((v) => AddOns.fromJson(v)))
    //     : (json['addons'] != null)
    //         ? List<AddOns>.from(json['addons'].map((v) => AddOns.fromJson(v)))
    //         : [];

    if (json['add_ons'] != null && json['add_ons'] is List) {
      // It's not null AND it's actually a List
      List<dynamic> addOnsData = json['add_ons']; // Cast to List<dynamic>
      if (addOnsData.isNotEmpty) {
        addOns = addOnsData.map((v) => AddOns.fromJson(v as Map<String, dynamic>)).toList();
      } else {
        addOns = []; // It's an empty list
      }
    } else {
      // It's null, not a list (e.g., it's the string "[]"), or some other incorrect type.
      // Decide how to handle this. Usually, defaulting to an empty list is safe.
      addOns = [];
      if (json['add_ons'] != null && json['add_ons'] is String && json['add_ons'] == "[]") {
        print("Warning: 'add_ons' field was received as the string '[]'. Treating as empty list.");
      } else if (json['add_ons'] != null) {
        print("Warning: 'add_ons' field was received with unexpected type: ${json['add_ons'].runtimeType}. Treating as empty list.");
      }
    }
    choiceOptions = (json['choice_options'] != null)
        ? List<ChoiceOptions>.from(
            json['choice_options'].map((v) => ChoiceOptions.fromJson(v)))
        : [];

    price = (json['price'] != null) ? json['price'].toDouble() : 0.0;
    tax = (json['tax'] != null) ? json['tax'].toDouble() : 0.0;
    discount = (json['discount'] != null) ? json['discount'].toDouble() : 0.0;

    discountType = json['discount_type'] ?? '';
    availableTimeStarts = json['available_time_starts'] ?? '';
    availableTimeEnds = json['available_time_ends'] ?? '';
    storeId = json['store_id'] ?? 0;
    storeName = json['store_name'] ?? '';
    zoneId = json['zone_id'] ?? 0;
    storeDiscount =
        (json['store_discount'] != null) ? json['store_discount'] : 0.0;
    scheduleOrder = json['schedule_order'] ?? false;
    avgRating =
        (json['avg_rating'] != null) ? json['avg_rating'].toDouble() : 0.0;
    ratingCount = json['rating_count'] ?? 0;
    moduleId = json['module_id'] ?? 0;
    moduleType = json['module_type'] ?? '';
    veg = (json['veg'] != null) ? int.parse(json['veg'].toString()) : 0;
    stock = json['stock'] ?? 0;
    unitType = json['unit_type'] ?? '';
    availableDateStarts = json['available_date_starts'] ?? '';
    organic = json['organic'] ?? 0;
    quantityLimit = json['maximum_cart_quantity'] ?? 0;
    flashSale = json['flash_sale'] ?? 0;

    isStoreHalalActive = json['halal_tag_status'] == 1;
    isHalalItem = json['is_halal'] == 1;
    isPrescriptionRequired = json['is_prescription_required'] == 1;

    nutritionsName = json['nutritions_name'] != null
        ? List<String>.from(json['nutritions_name'])
        : [];
    allergiesName = json['allergies_name'] != null
        ? List<String>.from(json['allergies_name'])
        : [];
    genericName = json['generic_name'] != null
        ? List<String>.from(json['generic_name'])
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['images_full_url'] = imagesFullUrl;
    data['category_id'] = categoryId;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (foodVariations != null) {
      data['food_variations'] = foodVariations!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    if (choiceOptions != null) {
      data['choice_options'] = choiceOptions!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    data['tax'] = tax;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['zone_id'] = zoneId;
    data['store_discount'] = storeDiscount;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['veg'] = veg;
    data['module_id'] = moduleId;
    data['module_type'] = moduleType;
    data['stock'] = stock;
    data['unit_type'] = unitType;
    data['available_date_starts'] = availableDateStarts;
    data['organic'] = organic;
    data['maximum_cart_quantity'] = quantityLimit;
    data['flash_sale'] = flashSale;
    data['halal_tag_status'] = isStoreHalalActive;
    data['is_halal'] = isHalalItem;
    data['is_prescription_required'] = isPrescriptionRequired;
    data['nutritions_name'] = nutritionsName;
    data['allergies_name'] = allergiesName;
    data['generic_name'] = genericName;
    return data;
  }
}

class CategoryIds {
  int? id;
  int? position;

  CategoryIds({this.id, this.position});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString()) ?? 0;
    position = int.tryParse(json['position'].toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    return data;
  }
}

class Variation {
  String? type;
  double? price;
  int? stock;

  Variation({this.type, this.price, this.stock});

  Variation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price']?.toDouble();
    stock = int.parse(json['stock'] != null ? json['stock'].toString() : '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
    data['stock'] = stock;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  double? price;

  AddOns({
    this.id,
    this.name,
    this.price,
  });

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}

class ChoiceOptions {
  String? name;
  String? title;
  List<String>? options;

  ChoiceOptions({this.name, this.title, this.options});

  ChoiceOptions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['title'] = title;
    data['options'] = options;
    return data;
  }
}

class FoodVariation {
  String? name;
  bool? multiSelect;
  int? min;
  int? max;
  bool? required;
  List<VariationValue>? variationValues;

  FoodVariation(
      {this.name,
      this.multiSelect,
      this.min,
      this.max,
      this.required,
      this.variationValues});

  FoodVariation.fromJson(Map<String, dynamic> json) {
    if (json['max'] != null) {
      name = json['name'];
      multiSelect = json['type'] == 'multi';
      min = multiSelect! ? int.parse(json['min'].toString()) : 0;
      max = multiSelect! ? int.parse(json['max'].toString()) : 0;
      required = json['required'] == 'on';
      if (json['values'] != null) {
        variationValues = [];
        json['values'].forEach((v) {
          variationValues!.add(VariationValue.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = multiSelect;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (variationValues != null) {
      data['values'] = variationValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationValue {
  String? level;
  String? image;
  double? optionPrice;
  bool? isSelected;

  VariationValue({this.level, this.image,this.optionPrice, this.isSelected});

  VariationValue.fromJson(Map<String, dynamic> json) {
    level = json['label'] ?? "";
    image = json['image'] ?? "";
    optionPrice = double.parse(json['optionPrice'].toString());
    isSelected = json['isSelected'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = level;
    data['image'] = image;
    data['optionPrice'] = optionPrice;
    data['isSelected'] = isSelected;
    return data;
  }
}
