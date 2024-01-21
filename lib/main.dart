import 'package:flutter/material.dart';
import 'product.dart';
import 'apiCalls.dart';
import 'favouriteProducts.dart';
import 'productDetailsPage.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(MyApp());
}

List<Product> gProductsToShow = [];
List<Product> gFavoriteProducts = [];
String gOrden = 'codigoasc';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String apiResponse = '';
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Call fetchData once at the beginning to load all products
    _fetchData('');
  }

  // Define a separate function for fetching data
  Future<void> _fetchData(String productId) async {
    try {
      var response = await ApiService.fetchData(productId, gOrden);
      List<dynamic> products = response['data'];
      gProductsToShow.clear();

      for (var product in products) {
        var productId = product['CodigoProducto'];
        var title = product['Titulo'];
        var price = product['Precio'];

        var newProduct = Product(
          productId: productId,
          title: title,
          price: price,
          img: 'http://82.98.132.218:6587/images/' + productId + '.jpg',
        );

        gProductsToShow.add(newProduct);
      }

      setState(() {});
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: 'GENEK test. Click to search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.deepPurple),
          onChanged: (value) {
            // Trigger API call with the content of the TextField after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              _fetchData(value);
            });
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              /*String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                "#ff6666", 
                "Cancel", 
                true, 
                ScanMode.BARCODE
              );*/
              String barcodeScanRes = "00002";
              //comment upper line to test with real barcode scanner
              Product product = await ApiService.fetchBarCode(barcodeScanRes);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(product: product),
                ),
              );
              print(barcodeScanRes);
            },
          ),
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteProductsPage(
                    onFavoritesChanged: () {
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_by_alpha),
            onSelected: (String value) {
              setState(() {
                gOrden = value;
                switch (value) {
                  case 'codigoasc':
                    gProductsToShow
                        .sort((a, b) => a.productId.compareTo(b.productId));
                    break;
                  case 'codigodesc':
                    gProductsToShow
                        .sort((a, b) => b.productId.compareTo(a.productId));
                    break;
                  case 'tituloasc':
                    gProductsToShow.sort((a, b) => a.title.compareTo(b.title));
                    break;
                  case 'titulodesc':
                    gProductsToShow.sort((a, b) => b.title.compareTo(a.title));
                    break;
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return ['codigoasc', 'codigodesc', 'tituloasc', 'titulodesc']
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: gProductsToShow.isEmpty
                ? const Center(
                    child: Text('No products found.'),
                  )
                : ListView.builder(
                    itemCount: gProductsToShow.length,
                    itemBuilder: (context, index) {
                      var product = gProductsToShow[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsPage(product: product),
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
                            SizedBox(
                                width:
                                    10), // Add some space between the image and the text
                            Expanded(
                              // Use Expanded to prevent overflow of text
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              icon: gFavoriteProducts.any(
                                      (p) => p.productId == product.productId)
                                  ? const Icon(Icons.star)
                                  : const Icon(Icons.star_border),
                              color: gFavoriteProducts.any(
                                      (p) => p.productId == product.productId)
                                  ? Colors.yellow
                                  : null,
                              onPressed: () {
                                if (gFavoriteProducts.any(
                                    (p) => p.productId == product.productId)) {
                                  setState(() {
                                    gFavoriteProducts.removeWhere((p) =>
                                        p.productId == product.productId);
                                  });
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
          ),
        ],
      ),
    );
  }
}
