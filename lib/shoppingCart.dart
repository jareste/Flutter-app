import 'package:flutter/material.dart';
import 'main.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  int quantityToRemove = 1;
  List<int> quantityOptions = [1, 3, 5, 10];

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    for (var item in gShoppingCart) {
      totalPrice += double.parse(item.product.price) * item.quantity;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: Column(
        children: <Widget>[
          Text('Total Price: ' + totalPrice.toString() + '€'),
          Expanded(
            child: ListView.builder(
              itemCount: gShoppingCart.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(gShoppingCart[index].product.title),
                  subtitle: Text(
                    'Quantity: ' + gShoppingCart[index].quantity.toString() +
                    '\nPrice: ' + (double.parse(gShoppingCart[index].product.price) *
                     gShoppingCart[index].quantity).toString() + '€'
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButton<int>(
                        value: quantityToRemove,
                        onChanged: (int? newValue) {
                          setState(() {
                            quantityToRemove = newValue!;
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
                          setState(() {
                            gShoppingCart[index].quantity -= quantityToRemove;
                            if (gShoppingCart[index].quantity <= 0) {
                              gShoppingCart.removeAt(index);
                            }
                          });
                        },
                        child: Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}