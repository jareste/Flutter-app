import 'package:flutter/material.dart';
import 'product.dart';
import 'apiCalls.dart';
import 'favouriteProducts.dart';
import 'productDetailsPage.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'shoppingCart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  await dotenv.load();
  runApp(MyApp());
}

List<Product> gProductsToShow = [];
List<Product> gFavoriteProducts = [];
String gOrden = 'codigoasc';
List<CartItem> gShoppingCart = [];
List<Product> gAllProducts = [];

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

Future<List<Product>> getStoredProducts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedProductsJson = prefs.getString('products');
  if (storedProductsJson != null) {
    List<dynamic> storedProductsList = jsonDecode(storedProductsJson);
    return storedProductsList.map((item) => Product.fromJson(item)).toList();
  } else {
    return [];
  }
}

Future<DateTime?> getLastRequestTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? lastRequestMillis = prefs.getInt('lastRequestTime');
  if (lastRequestMillis != null) {
    return null;
    //descomentar para que sea valido
    // return DateTime.fromMillisecondsSinceEpoch(lastRequestMillis);
  } else {
    return null;
  }
}

Future<void> storeProducts(List<Product> products) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String productsJson =
      jsonEncode(products.map((item) => item.toJson()).toList());
  await prefs.setString('products', productsJson);
}

Future<void> storeLastRequestTime(DateTime time) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastRequestTime', time.millisecondsSinceEpoch);
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    updateProductsIfNeeded();
  }

  Future<void> updateProductsIfNeeded() async {
    DateTime? lastRequestTime = await getLastRequestTime();
    if (lastRequestTime == null ||
        DateTime.now().difference(lastRequestTime) > Duration(minutes: 30)) {
      try {
        List<Product> products = await ApiService.fetchData('', gOrden);
        gAllProducts = products;
        gProductsToShow = List.from(gAllProducts);
        await storeProducts(products);
        await storeLastRequestTime(DateTime.now());
      } catch (e) {
        print('Failed to fetch products: $e');
        gAllProducts = await getStoredProducts();
        gProductsToShow = List.from(gAllProducts);
      }
    } else {
      gAllProducts = await getStoredProducts();
      gProductsToShow = List.from(gAllProducts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: updateProductsIfNeeded(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          return MaterialApp(
            themeMode: _themeMode,
            darkTheme: ThemeData.dark(),
            theme: ThemeData.light(),
            home: MyHomePage(toggleTheme: _toggleTheme),
          );
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function toggleTheme;

  MyHomePage({required this.toggleTheme});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String apiResponse = '';
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
              hintStyle: TextStyle(color: Color.fromARGB(255, 0, 148, 57)),
            ),
            style: const TextStyle(color: Color.fromARGB(255, 0, 148, 57)),
            onChanged: (value) {
              setState(() {
                gProductsToShow = gAllProducts.where((product) {
                  return product.title
                          .toLowerCase()
                          .contains(value.toLowerCase()) ||
                      product.productId
                          .toLowerCase()
                          .contains(value.toLowerCase());
                }).toList();
              });
            }),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                  "#ff6666", "Cancel", true, ScanMode.BARCODE);
              print('barcode----------------------------------$barcodeScanRes');
              try {
                Product product = await ApiService.fetchBarCode(barcodeScanRes);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(product: product),
                  ),
                );
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Invalid barcode'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }
          ),
          IconButton(
            icon: const Icon(Icons.star),
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
                  case '1-9':
                    gOrden = 'codigoasc';
                    gProductsToShow
                        .sort((a, b) => a.productId.compareTo(b.productId));
                    break;
                  case '9-1':
                    gOrden = 'codigodesc';
                    gProductsToShow
                        .sort((a, b) => b.productId.compareTo(a.productId));
                    break;
                  case 'A-Z':
                    gOrden = 'tituloasc';
                    gProductsToShow.sort((a, b) => a.title.compareTo(b.title));
                    break;
                  case 'Z-A':
                    gOrden = 'titulodesc';
                    gProductsToShow.sort((a, b) => b.title.compareTo(a.title));
                    break;
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return ['1-9', '9-1', 'A-Z', 'Z-A'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              widget.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingCartPage()),
              );
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
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  int defaultImageIndex =
                                      Random().nextInt(7) + 1;
                                  return Image.asset(
                                      'assets/images/peepo$defaultImageIndex.jpg');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
