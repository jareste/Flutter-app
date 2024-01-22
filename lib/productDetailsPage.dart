import 'package:flutter/material.dart';
import 'product.dart';


class ProductDetailsPage extends StatelessWidget {
  final Product product;

  ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title,
            style: TextStyle(fontSize: 20, color: Colors.black)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Image.network(
                product.img,
                fit: BoxFit.fill,
              ),
            ),
            Text(product.price + '€',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            Text(product.productId),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}