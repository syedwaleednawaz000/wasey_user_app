import 'package:sixam_mart/features/store/domain/models/store_model.dart';

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
