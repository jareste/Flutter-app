import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static Future<List<Product>> fetchData(String productId, String orden) async {
    String apiKey = dotenv.env['APIKEY'] ?? '';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'token': apiKey,
    };
    final response = await http.get(
      //orden values = codigoasc,codigodesc,tituloasc,titulodesc
      Uri.parse((dotenv.env['APISEARCH'] ?? '') + '${productId}&orden=${orden}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('Response:');
      print(response.body);
      List<dynamic> dataList = json.decode(response.body)['data'];
      List<Product> products =
          dataList.map<Product>((item) => Product.fromJson(item)).toList();
      return products;
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }

  static Future<Product> fetchBarCode(String productID) async {
    String apiKey = dotenv.env['APIKEY'] ?? '';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'token': apiKey,
    };
    final response = await http.get(
      //orden values = codigoasc,codigodesc,tituloasc,titulodesc
      Uri.parse((dotenv.env['APISEARCH'] ?? '') + productID),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)['data'];
      Map<String, dynamic> data = dataList[0];
      Product product = Product(
        productId: data['CodigoProducto'],
        title: data['Titulo'],
        price: data['Precio'],
        img: (dotenv.env['IMGURL'] ?? '') + productID + '.jpg',
      );
      return product;
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }
}
