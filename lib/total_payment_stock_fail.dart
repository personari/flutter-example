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

class TotalPaymentStockFail extends StatelessWidget {
  // You can ask Get to find a Controller that is being used by another page and redirect you to it.

  String webApplicationId = '66d9414b4fb27baaf86e4a8c';
  String androidApplicationId = '66d9414b4fb27baaf86e4a8a';
  String iosApplicationId = '66d9414b4fb27baaf86e4a8b';

  @override
  Widget build(context) {
    // Access the updated count variable
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: TextButton(
                    onPressed: () => bootpayTest(context),
                    child: const Text('통합결제 테스트', style: TextStyle(fontSize: 16.0))
                )
            )
        )
    );
  }

  void bootpayTest(BuildContext context) {
    Payload payload = getPayload();
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
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirm: (String data) {
        print('------- onConfirm: $data');
        /**
            1. 바로 승인하고자 할 때
            return true;
         **/
        /***
            2. 비동기 승인 하고자 할 때
            checkQtyFromServer(data);
            return false;
         ***/
        /***
            3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
            return false; 후에 서버에서 결제승인 수행
         */
        // checkQtyFromServer(data);
        // return true;

        toServer(data);
        return false;
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

  //* 잘못된 item 정보
  Payload getPayload() {
    Payload payload = Payload();
    Item item1 = Item();
    item1.name = "껌"; // 주문정보에 담길 상품명
    item1.qty = 2; // 해당 상품의 주문 수량
    item1.id = "6"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격

    Item item2 = Item();
    item2.name = "사탕"; // 주문정보에 담길 상품명
    item2.qty = 3; // 해당 상품의 주문 수량
    item2.id = "7"; // 해당 상품의 고유 키
    item2.price = 300; // 상품의 가격
    List<Item> itemList = [item1, item2];

    payload.webApplicationId = webApplicationId; // web application id
    payload.androidApplicationId = androidApplicationId; // android application id
    payload.iosApplicationId = iosApplicationId; // ios application id


    payload.pg = '나이스페이';
    // payload.method = '카드';
    // payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao'];
    payload.orderName = "테스트 상품"; //결제할 상품명
    payload.price = 1900.0; //정기결제시 0 혹은 주석


    payload.orderId = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString(); //주문번호, 개발사에서 고유값으로 지정해야함

    payload.items = itemList; // 상품정보 배열

    User user = User(); // 구매자 정보
    user.username = "사용자 이름";
    user.email = "user1234@gmail.com";
    user.area = "서울";
    user.phone = "010-4033-4678";
    user.addr = '서울시 동작구 상도로 222';

    Extra extra = Extra(); // 결제 옵션
    extra.appScheme = 'bootpayFlutterExample';
    extra.cardQuota = '3';
    extra.separatelyConfirmed = true;
    extra.openType = 'popup';

    // extra.carrier = "SKT,KT,LGT"; //본인인증 시 고정할 통신사명
    // extra.ageLimit = 20; // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능

    payload.user = user;
    payload.extra = extra;


    payload.metadata = {
      "items": itemList,
      "user" : user,
      "callbackParam1": "value12",
      "callbackParam2": "value34",
      "callbackParam3": "value56",
      "callbackParam4": "value78",
    }; // 전달할 파라미터, 결제 후 되돌려 주는 값
    return payload;
  }

  void toServer(String data) async {
    final url = Uri.http("localhost:8080", "/order/confirm",);

    Map<String,String> headers = {
      'Content-type' : 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(url, headers : headers, body: data);


  }

}
