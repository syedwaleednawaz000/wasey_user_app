import 'package:sixam_mart/features/store/domain/models/store_model.dart';

import 'package:sixam_mart/features/store/domain/models/category_with_stores.dart';

class PaginatedCategoryWithStores {
  final int totalCategories;
  final int categoryLimit;
  final int categoryOffset;
  final List<CategoryWithStores> categories;

  PaginatedCategoryWithStores({
    required this.totalCategories,
    required this.categoryLimit,
    required this.categoryOffset,
    required this.categories,
  });

  factory PaginatedCategoryWithStores.fromJson(Map<String, dynamic> json) {
    return PaginatedCategoryWithStores(
      // Use ?? 0 as a fallback to prevent null errors if the API ever omits a key
      totalCategories: json['total_categories'] as int? ?? 0,
      categoryLimit: json['category_limit'] as int? ?? 0,
      categoryOffset: json['category_offset'] as int? ?? 0,

      // Safely parse the list of categories
      categories: (json['categories'] as List<dynamic>?)
          ?.map((v) => CategoryWithStores.fromJson(v as Map<String, dynamic>))
          .toList() ?? // Use an empty list as a fallback
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'total_categories': totalCategories,
    'category_limit': categoryLimit,
    'category_offset': categoryOffset,
    'categories': categories.map((v) => v.toJson()).toList(),
  };
}


class CategoryWithStores {
  String? cName;
  int? cId;
  List<Store>? stores;

  CategoryWithStores({
    this.cName,
    this.cId,
    this.stores,
  });

  factory CategoryWithStores.fromJson(Map<String, dynamic> json) {
    return CategoryWithStores(
      cName: json['c_name'] as String?,
      cId: json['c_id'] as int?,
      stores: (json['stores'] as List<dynamic>?)
          ?.map((v) => Store.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (cName != null) 'c_name': cName,
    if (cId != null) 'c_id': cId,
    if (stores != null) 'stores': stores!.map((v) => v.toJson()).toList(),
  };
}
