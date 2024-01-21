import 'package:flutter/material.dart';
import 'main.dart';
import 'productDetailsPage.dart';

class FavoriteProductsPage extends StatefulWidget {
  final VoidCallback onFavoritesChanged;

  FavoriteProductsPage({required this.onFavoritesChanged});

  @override
  _FavoriteProductsPageState createState() => _FavoriteProductsPageState();
}

class _FavoriteProductsPageState extends State<FavoriteProductsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Products'),
      ),
      body: ListView.builder(
        itemCount: gFavoriteProducts.length,
        itemBuilder: (context, index) {
          var product = gFavoriteProducts[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(product: product),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  child: Image.network(
                    product.img,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10), // Add some space between the image and the text
                Expanded(
                  // Use Expanded to prevent overflow of text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.productId),
                          Text(product.title),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(product.price + '€'),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: gFavoriteProducts.contains(product)
                      ? const Icon(Icons.star)
                      : const Icon(Icons.star_border),
                  color: gFavoriteProducts.contains(product)
                      ? Colors.yellow
                      : null,
                  onPressed: () {
                    if (gFavoriteProducts.contains(product)) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Remove from favorites'),
                            content: const Text('Do you want to remove this product from your favorites?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Remove'),
                                onPressed: () {
                                  setState(() {
                                    gFavoriteProducts.remove(product);
                                  });
                                  widget.onFavoritesChanged();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      setState(() {
                        gFavoriteProducts.add(product);
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
