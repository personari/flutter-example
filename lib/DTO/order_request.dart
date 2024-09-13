import 'package:bootpay/model/payload.dart';
import 'package:pg_test_flutter/DTO/item_order.dart';

class OrderRequestDTO {
  final List<ItemOrderDTO> itemOrderList;
  final int totalPrice;
  final int projectId;
  final int memberId;
  final String ordererName;
  final String ordererPhoneNumber;

  OrderRequestDTO({
    required this.itemOrderList,
    required this.totalPrice,
    required this.projectId,
    required this.memberId,
    required this.ordererName,
    required this.ordererPhoneNumber,
  });

  // JSON을 Dart 객체로 변환하는 factory constructor
  factory OrderRequestDTO.fromJson(Map<String, dynamic> json) {
    var itemList = (json['itemOrderList'] as List)
        .map((item) => ItemOrderDTO.fromJson(item))
        .toList();

    return OrderRequestDTO(
      itemOrderList: itemList,
      totalPrice: json['totalPrice'],
      projectId: json['projectId'],
      memberId: json['memberId'],
      ordererName: json['ordererName'],
      ordererPhoneNumber: json['ordererPhoneNumber'],
    );
  }

  // JSON을 Dart 객체로 변환하는 factory constructor
  factory OrderRequestDTO.fromPayload({required int projectId, required Payload payload}) {
    final itemList = payload.items?.map((item)=>ItemOrderDTO.fromItem(item)).toList();
    final totalPrice = payload.price;
    final memberId = payload.user?.id;
    final ordererName = payload.user?.username;
    final ordererPhoneNumber = payload.user?.phone;

    assert(itemList != null);
    assert(totalPrice != null);
    assert(memberId != null);
    assert(ordererName != null);
    assert(ordererPhoneNumber != null);

    return OrderRequestDTO(
      itemOrderList: itemList!,
      totalPrice: totalPrice!.floor(),
      projectId: projectId,
      memberId: int.parse(memberId!),
      ordererName: ordererName!,
      ordererPhoneNumber: ordererPhoneNumber!,
    );
  }

  // Dart 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'itemOrderList': itemOrderList.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'projectId': projectId,
      'memberId': memberId,
      'ordererName': ordererName,
      'ordererPhoneNumber': ordererPhoneNumber,
    };
  }
}