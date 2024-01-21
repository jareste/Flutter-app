import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';

class ApiService {
  static Future<Map<String, dynamic>> fetchData(
      String productId, String orden) async {
    // Define your custom headers
    //String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOiI2Yzc4YWYxYS0yZTdlLTQ5ZDMtYjAxNS1lZDI3YTlmNDgzNWQiLCJub21icmVVc3VhcmlvIjoidGVzdHdlYiIsImlhdCI6MTcwNTA1NzAyMSwiaXNzIjoiaHR0cHM6Ly93d3cuYWR6Z2kuY29tIiwianRpIjoiIn0.J9SasbEaxwU2hlG5YRpDEeEJc8vZgb6cVYzj3cRNo84';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'token':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOiI2Yzc4YWYxYS0yZTdlLTQ5ZDMtYjAxNS1lZDI3YTlmNDgzNWQiLCJub21icmVVc3VhcmlvIjoidGVzdHdlYiIsImlhdCI6MTcwNTA1NzAyMSwiaXNzIjoiaHR0cHM6Ly93d3cuYWR6Z2kuY29tIiwianRpIjoiIn0.J9SasbEaxwU2hlG5YRpDEeEJc8vZgb6cVYzj3cRNo84', // Replace with your actual access token
      //'token': apiKey,
    };
    final response = await http.get(
      //orden values = codigoasc,codigodesc,tituloasc,titulodesc
      Uri.parse(
          'http://82.98.132.218:6587/api/productos?buscar=${productId}&orden=${orden}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('Response:');
      print(response.body);
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }

  static Future<Product> fetchBarCode(String productID) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'token':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOiI2Yzc4YWYxYS0yZTdlLTQ5ZDMtYjAxNS1lZDI3YTlmNDgzNWQiLCJub21icmVVc3VhcmlvIjoidGVzdHdlYiIsImlhdCI6MTcwNTA1NzAyMSwiaXNzIjoiaHR0cHM6Ly93d3cuYWR6Z2kuY29tIiwianRpIjoiIn0.J9SasbEaxwU2hlG5YRpDEeEJc8vZgb6cVYzj3cRNo84', // Replace with your actual access token
      //'token': apiKey,
    };
    final response = await http.get(
      //orden values = codigoasc,codigodesc,tituloasc,titulodesc
      Uri.parse('http://82.98.132.218:6587/api/productos?buscar=$productID'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> dataList = json.decode(response.body)['data'];
      Map<String, dynamic> data = dataList[0];
      Product product = Product(
        productId: data['CodigoProducto'],
        title: data['Titulo'],
        price: data['Precio'],
        img: 'http://82.98.132.218:6587/images/' + productID + '.jpg',
      );
      return product;
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }
}
