import 'package:flutter_dotenv/flutter_dotenv.dart';

class Product {
  String productId;
  String title;
  String price;
  String img;

  Product({
    required this.productId,
    required this.title,
    required this.price,
    required this.img,
  });

  Map<String, dynamic> toJson() {
    return {
      'CodigoProducto': productId,
      'Titulo': title,
      'Precio': price,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['CodigoProducto'],
      title: json['Titulo'],
      price: json['Precio'],
      img: (dotenv.env['IMGURL'] ?? '') + json['CodigoProducto'] + '.jpg',
    );
  }
}
