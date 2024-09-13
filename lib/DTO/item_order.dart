import 'package:bootpay/model/item.dart';

class ItemOrderDTO {
  final int itemId;
  final int quantity;

  ItemOrderDTO({required this.itemId, required this.quantity});

  // JSON을 Dart 객체로 변환하는 factory constructor
  factory ItemOrderDTO.fromJson(Map<String, dynamic> json) {
    return ItemOrderDTO(
      itemId: json['itemId'],
      quantity: json['quantity'],
    );
  }

  // JSON을 Dart 객체로 변환하는 factory constructor
  factory ItemOrderDTO.fromItem(Item item) {
    if(item.id == null) throw Exception("");
    if(item.qty == null) throw Exception("");

    return ItemOrderDTO(
      itemId: int.parse(item.id!),
      quantity: item.qty!
    );
  }

  // Dart 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'quantity': quantity,
    };
  }


}