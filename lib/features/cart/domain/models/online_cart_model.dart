import 'package:flutter/material.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart'
    as product_variation;

class OnlineCartModel {
  int? id;
  int? userId;
  int? moduleId;
  int? itemId;
  bool? isGuest;
  List<int>? addOnIds;
  List<int>? addOnQtys;
  String? itemType;
  double? price;
  int? quantity;
  List<Variation>? foodVariation;
  List<product_variation.Variation>? productVariation;
  String? createdAt;
  String? updatedAt;
  product_variation.Item? item;

  OnlineCartModel({
    this.id,
    this.userId,
    this.moduleId,
    this.itemId,
    this.isGuest,
    this.addOnIds,
    this.addOnQtys,
    this.itemType,
    this.price,
    this.quantity,
    this.foodVariation,
    this.createdAt,
    this.updatedAt,
    this.item,
  });

  OnlineCartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    moduleId = json['module_id'];
    itemId = json['item_id'];
    isGuest = json['is_guest'];
    addOnIds = json['add_on_ids'].cast<int>();
    addOnQtys = json['add_on_qtys'].cast<int>();
    itemType = json['item_type'];
    price = json['price']?.toDouble();
    quantity = json['quantity'];
    if (json['variation'] != null) {
      // debugPrint('fromJson OnlineCartModel ===> variation: ${json['variation']}');
      foodVariation = [];
      productVariation = [];
      json['variation'].forEach((v) {
        // if (v['name'] == null) {
          if ('${json['module_id']}' == '2') {
            foodVariation!.add(Variation.fromJson(v));
          } else {
            productVariation!.add(product_variation.Variation.fromJson(v));
          }
        // }
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    item = json['item'] != null
        ? product_variation.Item.fromJson(json['item'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // debugPrint('toJson ===> foodVariation: ${foodVariation}');
    // debugPrint('toJson ===> productVariation: ${productVariation}');
    data['id'] = id;
    data['user_id'] = userId;
    data['module_id'] = moduleId;
    data['item_id'] = itemId;
    data['is_guest'] = isGuest;
    data['add_on_ids'] = addOnIds;
    data['add_on_qtys'] = addOnQtys;
    data['item_type'] = itemType;
    data['price'] = price;
    data['quantity'] = quantity;
    if (foodVariation != null) {
      data['foodVariation'] = foodVariation!.map((v) {
        // debugPrint('toJson ===> v: ${v.toJson()}');
        return v.toJson();}).toList();
      // debugPrint('toJson ===> data: ${data['foodVariation']}');
    }
    if (productVariation != null) {
      data['variation'] = productVariation!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (item != null) {
      data['item'] = item!.toJson();
    }
    return data;
  }
}

class Variation {
  String? name;
  Value? values;

  Variation({this.name, this.values});

  Variation.fromJson(Map<String, dynamic> json) {
    // debugPrint('fromJson Variation ===> values: ${json['values']}');
    name = json['name'];
    values = json['values'] != null ? Value.fromJson(json['values']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (values != null) {
      data['values'] = values!.toJson();
    }
    return data;
  }
}

class Value {
  List<String>? label;
  List<String>? toppingOptions;

  Value({this.label, this.toppingOptions});

  Value.fromJson(Map<String, dynamic> json) {
    // debugPrint('fromJson Value ===> toppingOptions: ${json['toppingOptions']}');
    label = json['label'] != null ? List<String>.from(json['label']) : [];
    // Filter out null values from toppingOptions
    if (json['toppingOptions'] != null) {
      toppingOptions = List<String>.from(
          json['toppingOptions'].where((item) => item != null).map((item) => item.toString())
      );
    } else {
      toppingOptions = [];
    }
    // toppingOptions = json['toppingOptions'] != null
    //     ? List<String>.from(json['toppingOptions']??"")
    //     : [];
  }
  // Value.fromJson(Map<String, dynamic> json) {
  //   label = json['label'].cast<String>();
  //   toppingOptions = json['toppingOptions'].cast<String>();
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['toppingOptions'] = toppingOptions;
    return data;
  }
}
