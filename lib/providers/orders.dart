import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:my_app_shop/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url =
        'https://shop-app-68784-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null){
        return;
      }
      final List<OrderItem> listOrders = [];
      extractedData.forEach((key, value) {
        listOrders.add(OrderItem(
          id: key,
          amount: value['amount'],
          dateTime: DateTime.parse(value['dateTime']),
          products: (value['products'] as List<dynamic>)
              .map((e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  price: e['price'],
                  quantity: e['quantity']))
              .toList(),
        ));
      });
      _orders = listOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url =
        'https://shop-app-68784-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json';
    final timestamp = DateTime.now();
    final reponse = await http.post(Uri.parse(url),
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'price': e.price,
                    'quantity': e.quantity
                  })
              .toList(),
          'dateTime': timestamp.toIso8601String(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(reponse.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timestamp,
      ),
    );
  }
}
