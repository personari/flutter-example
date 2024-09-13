import 'dart:convert';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pg_test_flutter/DTO/order_request.dart';
String webApplicationId = '66d9414b4fb27baaf86e4a8c';
String androidApplicationId = '66d9414b4fb27baaf86e4a8a';
String iosApplicationId = '66d9414b4fb27baaf86e4a8b';
int globalOrderId = 0;
class TotalPayment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>  _TotalPaymentState();

}

class _TotalPaymentState extends State<TotalPayment>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: TextButton(
                    onPressed: () {
                      setReservation(getPayload()).then((e) =>bootpayTest(context, e));
                    },
                    child: const Text('통합결제 테스트', style: TextStyle(fontSize: 16.0))
                )
            )
        )
    );


  }

  void bootpayTest(BuildContext context, int orderId) {
    Payload payload = getPayload(orderId);

    if (kIsWeb) {
      payload.extra?.openType = 'popup';
    }

    Bootpay().requestPayment(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel: $data');
      },
      onError: (String data) {
        print('------- onError: $data');
      },
      onClose: () {
        // onCloseTest();
        print('------- onClose');
        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirmAsync: (String data) async {
        print('------- onConfirm: $data');


        Bootpay().dismiss(context);
        return await toServer(data);
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

  Payload getPayload([int? orderId]) {
    Payload payload = Payload();
    Item item1 = Item();
    item1.name = "껌"; // 주문정보에 담길 상품명
    item1.qty = 2; // 해당 상품의 주문 수량
    item1.id = "6"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격

    Item item2 = Item();
    item2.name = "사탕"; // 주문정보에 담길 상품명
    item2.qty = 1; // 해당 상품의 주문 수량
    item2.id = "7"; // 해당 상품의 고유 키
    item2.price = 300; // 상품의 가격
    List<Item> itemList = [item1, item2];

    payload.webApplicationId = webApplicationId; // web application id
    payload.androidApplicationId = androidApplicationId; // android application id
    payload.iosApplicationId = iosApplicationId; // ios application id

    User user = User(); // 구매자 정보
    user.username = "홍길동";
    user.email = "user1234@gmail.com";
    user.area = "서울";
    user.phone = "010-3363-0371";
    user.addr = '서울시 동작구 상도로 222';
    user.id = "1";

    Extra extra = Extra(); // 결제 옵션
    extra.appScheme = 'bootpayFlutterExample';
    extra.cardQuota = '3';
    extra.separatelyConfirmed = true;
    extra.openType = 'popup';

    payload.metadata = {
      "items": itemList,
      "user" : user,
      "callbackParam1": "value12",
      "callbackParam2": "value34",
      "callbackParam3": "value56",
      "callbackParam4": "value78",
    };

    payload.user = user;
    payload.extra = extra;
    payload.pg = '나이스페이';
    payload.orderName = "테스트 상품"; //결제할 상품명
    payload.price = 1300.0; //정기결제시 0 혹은 주석
    payload.orderId = orderId.toString();
    payload.items = itemList;

    return payload;
  }

  Future<bool> toServer(String data) async {

    final url = Uri.http("localhost:8080", "/order/confirm",);

    Map<String,String> headers = {
      'Content-type' : 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(url, headers : headers, body: data);

    if(response.statusCode == 200) return true;
    return false;
  }

  Future<int> setReservation(Payload payload) async{
    final url = Uri.http("localhost:8080", "/order",);

    Map<String,String> headers = {
      'Content-type' : 'application/json',
      'Accept': 'application/json',
    };

    var orderRequest = OrderRequestDTO.fromPayload(payload: payload, projectId: 1);

    var result = await http.post(url, headers : headers, body: jsonEncode(orderRequest));

    final int orderId = jsonDecode(result.body)["id"];
    return orderId;
  }
}