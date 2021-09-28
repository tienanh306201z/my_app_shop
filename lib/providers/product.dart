import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.price,
      this.isFavorite = false});

  Future<void> toggleChangeFavoriteStatus() async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://shop-app-68784-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json';
    try {
      await http.patch(Uri.parse(url),
          body: json.encode({
            'isFavorite': isFavorite,
          }));
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
