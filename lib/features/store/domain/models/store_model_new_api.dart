import 'package:sixam_mart/features/item/domain/models/item_model.dart';

class ItemNewApiModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<StoreCategories>? categories;

  ItemNewApiModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.categories,
  });

  factory ItemNewApiModel.fromJson(Map<String, dynamic> json) => ItemNewApiModel(
    totalSize: json['total_size'] as int?,
    limit: json['limit'] as int?,
    offset: json['offset'] as int?,
    categories: (json['categories'] as List<dynamic>?)
        ?.map((v) => StoreCategories.fromJson(v as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    if (totalSize != null) 'total_size': totalSize,
    if (limit != null) 'limit': limit,
    if (offset != null) 'offset': offset,
    if (categories != null) 'categories': categories!.map((v) => v.toJson()).toList(),
  };
}

class StoreCategories {
  int? id;
  String? name;
  String? image;
  int? parentId;
  int? position;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? priority;
  int? moduleId;
  String? slug;
  int? featured;
  String? imageFullUrl;
  List<Storage>? storage;
  List<Translations>? translations;
  List<Item>? items;

  StoreCategories({
    this.id,
    this.name,
    this.image,
    this.parentId,
    this.position,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.priority,
    this.moduleId,
    this.slug,
    this.featured,
    this.imageFullUrl,
    this.storage,
    this.translations,
    this.items,
  });

  factory StoreCategories.fromJson(Map<String, dynamic> json) => StoreCategories(
    id: json['id'] as int?,
    name: json['name'] as String?,
    image: json['image'] as String?,
    parentId: json['parent_id'] as int?,
    position: json['position'] as int?,
    status: json['status'] as int?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
    priority: json['priority'] as int?,
    moduleId: json['module_id'] as int?,
    slug: json['slug'] as String?,
    featured: json['featured'] as int?,
    imageFullUrl: json['image_full_url'] as String?,
    storage: (json['storage'] as List<dynamic>?)
        ?.map((v) => Storage.fromJson(v as Map<String, dynamic>))
        .toList(),
    translations: (json['translations'] as List<dynamic>?)
        ?.map((v) => Translations.fromJson(v as Map<String, dynamic>))
        .toList(),
    items: (json['items'] as List<dynamic>?)
        ?.map((v) => Item.fromJson(v as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (image != null) 'image': image,
    if (parentId != null) 'parent_id': parentId,
    if (position != null) 'position': position,
    if (status != null) 'status': status,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
    if (priority != null) 'priority': priority,
    if (moduleId != null) 'module_id': moduleId,
    if (slug != null) 'slug': slug,
    if (featured != null) 'featured': featured,
    if (imageFullUrl != null) 'image_full_url': imageFullUrl,
    if (storage != null) 'storage': storage!.map((v) => v.toJson()).toList(),
    if (translations != null) 'translations': translations!.map((v) => v.toJson()).toList(),
    if (items != null) 'items': items!.map((v) => v.toJson()).toList(),
  };
}

class Storage {
  int? id;
  String? dataType;
  String? dataId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Storage({
    this.id,
    this.dataType,
    this.dataId,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  factory Storage.fromJson(Map<String, dynamic> json) => Storage(
    id: json['id'] as int?,
    dataType: json['data_type'] as String?,
    dataId: json['data_id'] as String?,
    key: json['key'] as String?,
    value: json['value'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (dataType != null) 'data_type': dataType,
    if (dataId != null) 'data_id': dataId,
    if (key != null) 'key': key,
    if (value != null) 'value': value,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}

class Translations {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translations({
    this.id,
    this.translationableType,
    this.translationableId,
    this.locale,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  factory Translations.fromJson(Map<String, dynamic> json) => Translations(
    id: json['id'] as int?,
    translationableType: json['translationable_type'] as String?,
    translationableId: json['translationable_id'] as int?,
    locale: json['locale'] as String?,
    key: json['key'] as String?,
    value: json['value'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (translationableType != null) 'translationable_type': translationableType,
    if (translationableId != null) 'translationable_id': translationableId,
    if (locale != null) 'locale': locale,
    if (key != null) 'key': key,
    if (value != null) 'value': value,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}

// class StoreItems {
//   int? id;
//   String? name;
//   String? description;
//   String? imageFullUrl;
//   List<dynamic>? imagesFullUrl;
//   int? categoryId;
//   List<Map<String, dynamic>>? categoryIds;
//   List<dynamic>? variations;
//   List<dynamic>? foodVariations;
//   List<dynamic>? addOns;
//   List<dynamic>? choiceOptions;
//   double? price;
//   double? tax;
//   dynamic discount;
//   String? discountType;
//   String? availableTimeStarts;
//   String? availableTimeEnds;
//   int? storeId;
//   String? storeName;
//   int? zoneId;
//   int? storeDiscount;
//   bool? scheduleOrder;
//   double? avgRating;
//   int? ratingCount;
//   int? veg;
//   int? moduleId;
//   String? moduleType;
//   int? stock;
//   String? unitType;
//   String? availableDateStarts;
//   int? organic;
//   int? maximumCartQuantity;
//   int? flashSale;
//   int? isPrescriptionRequired;
//   int? halalTagStatus;
//   int? isHalal;
//   List<dynamic>? nutritionsName;
//   List<dynamic>? allergiesName;
//   List<dynamic>? genericName;
//
//   StoreItems({
//     this.id,
//     this.name,
//     this.description,
//     this.imageFullUrl,
//     this.imagesFullUrl,
//     this.categoryId,
//     this.categoryIds,
//     this.variations,
//     this.foodVariations,
//     this.addOns,
//     this.choiceOptions,
//     this.price,
//     this.tax,
//     this.discount,
//     this.discountType,
//     this.availableTimeStarts,
//     this.availableTimeEnds,
//     this.storeId,
//     this.storeName,
//     this.zoneId,
//     this.storeDiscount,
//     this.scheduleOrder,
//     this.avgRating,
//     this.ratingCount,
//     this.veg,
//     this.moduleId,
//     this.moduleType,
//     this.stock,
//     this.unitType,
//     this.availableDateStarts,
//     this.organic,
//     this.maximumCartQuantity,
//     this.flashSale,
//     this.isPrescriptionRequired,
//     this.halalTagStatus,
//     this.isHalal,
//     this.nutritionsName,
//     this.allergiesName,
//     this.genericName,
//   });
//
//   factory StoreItems.fromJson(Map<String, dynamic> json) => StoreItems(
//     id: json['id'] as int?,
//     name: json['name'] as String?,
//     description: json['description'] as String?,
//     imageFullUrl: json['image_full_url'] as String?,
//     imagesFullUrl: (json['images_full_url'] as List<dynamic>?) ?? [],
//     categoryId: json['category_id'] as int?,
//     categoryIds: (json['category_ids'] as List<dynamic>?)
//         ?.map((v) => Map<String, dynamic>.from(v as Map))
//         .toList(),
//     variations: (json['variations'] as List<dynamic>?) ?? [],
//     foodVariations: (json['food_variations'] as List<dynamic>?) ?? [],
//     addOns: (json['add_ons'] as List<dynamic>?) ?? [],
//     choiceOptions: (json['choice_options'] as List<dynamic>?) ?? [],
//     price: (json['price'] as num?)?.toDouble(),
//     tax: (json['tax'] as num?)?.toDouble(),
//     discount: (json['discount'] as num?)?.toDouble(),
//     discountType: json['discount_type'] as String?,
//     availableTimeStarts: json['available_time_starts'] as String?,
//     availableTimeEnds: json['available_time_ends'] as String?,
//     storeId: json['store_id'] as int?,
//     storeName: json['store_name'] as String?,
//     zoneId: json['zone_id'] as int?,
//     storeDiscount: json['store_discount'] as int?,
//     scheduleOrder: json['schedule_order'] as bool?,
//     avgRating: (json['avg_rating'] as num?)?.toDouble(),
//     ratingCount: json['rating_count'] as int?,
//     veg: json['veg'] as int?,
//     moduleId: json['module_id'] as int?,
//     moduleType: json['module_type'] as String?,
//     stock: json['stock'] as int?,
//     unitType: json['unit_type'] as String?,
//     availableDateStarts: json['available_date_starts'] as String?,
//     organic: json['organic'] as int?,
//     maximumCartQuantity: json['maximum_cart_quantity'] as int?,
//     flashSale: json['flash_sale'] as int?,
//     isPrescriptionRequired: json['is_prescription_required'] as int?,
//     halalTagStatus: json['halal_tag_status'] as int?,
//     isHalal: json['is_halal'] as int?,
//     nutritionsName: (json['nutritions_name'] as List<dynamic>?) ?? [],
//     allergiesName: (json['allergies_name'] as List<dynamic>?) ?? [],
//     genericName: (json['generic_name'] as List<dynamic>?) ?? [],
//   );
//
//   Map<String, dynamic> toJson() => {
//     if (id != null) 'id': id,
//     if (name != null) 'name': name,
//     if (description != null) 'description': description,
//     if (imageFullUrl != null) 'image_full_url': imageFullUrl,
//     if (imagesFullUrl != null) 'images_full_url': imagesFullUrl,
//     if (categoryId != null) 'category_id': categoryId,
//     if (categoryIds != null) 'category_ids': categoryIds,
//     if (variations != null) 'variations': variations,
//     if (foodVariations != null) 'food_variations': foodVariations,
//     if (addOns != null) 'add_ons': addOns,
//     if (choiceOptions != null) 'choice_options': choiceOptions,
//     if (price != null) 'price': price,
//     if (tax != null) 'tax': tax,
//     if (discount != null) 'discount': discount,
//     if (discountType != null) 'discount_type': discountType,
//     if (availableTimeStarts != null) 'available_time_starts': availableTimeStarts,
//     if (availableTimeEnds != null) 'available_time_ends': availableTimeEnds,
//     if (storeId != null) 'store_id': storeId,
//     if (storeName != null) 'store_name': storeName,
//     if (zoneId != null) 'zone_id': zoneId,
//     if (storeDiscount != null) 'store_discount': storeDiscount,
//     if (scheduleOrder != null) 'schedule_order': scheduleOrder,
//     if (avgRating != null) 'avg_rating': avgRating,
//     if (ratingCount != null) 'rating_count': ratingCount,
//     if (veg != null) 'veg': veg,
//     if (moduleId != null) 'module_id': moduleId,
//     if (moduleType != null) 'module_type': moduleType,
//     if (stock != null) 'stock': stock,
//     if (unitType != null) 'unit_type': unitType,
//     if (availableDateStarts != null) 'available_date_starts': availableDateStarts,
//     if (organic != null) 'organic': organic,
//     if (maximumCartQuantity != null) 'maximum_cart_quantity': maximumCartQuantity,
//     if (flashSale != null) 'flash_sale': flashSale,
//     if (isPrescriptionRequired != null) 'is_prescription_required': isPrescriptionRequired,
//     if (halalTagStatus != null) 'halal_tag_status': halalTagStatus,
//     if (isHalal != null) 'is_halal': isHalal,
//     if (nutritionsName != null) 'nutritions_name': nutritionsName,
//     if (allergiesName != null) 'allergies_name': allergiesName,
//     if (genericName != null) 'generic_name': genericName,
//   };
// }