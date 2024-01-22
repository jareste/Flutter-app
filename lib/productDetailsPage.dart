import 'package:flutter/material.dart';
import 'product.dart';
import 'dart:math';
import 'main.dart';
import 'shoppingCart.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  ProductDetailsPage({required this.product});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  List<int> quantityOptions = [1, 3, 5, 10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title,
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
                widget.product.img,
                fit: BoxFit.fill,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  int defaultImageIndex = Random().nextInt(7) + 1;
                  return Image.asset('assets/images/peepo$defaultImageIndex.jpg');
                },
              ),
            ),
            Text(widget.product.price + '€',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            Text(widget.product.productId),
            DropdownButton<int>(
              value: quantity,
              onChanged: (int? newValue) {
                setState(() {
                  quantity = newValue!;
                });
              },
              items: quantityOptions.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                var existingCartItem = gShoppingCart.firstWhere(
                  (item) => item.product.productId == widget.product.productId,
                  orElse: () => CartItem(product: widget.product, quantity: 0),
                );

                if (existingCartItem.quantity > 0) {
                  existingCartItem.quantity += quantity;
                } else {
                  existingCartItem.quantity = quantity;
                  gShoppingCart.add(existingCartItem);
                }
              },
              child: Text('Add to cart'),
            )
          ],
        ),
      ),
    );
  }
}