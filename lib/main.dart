import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

int _totalPrice = 0;


class ShopProduct {
  final String title;
  final String description;
  final String picture;
  final String price;

  ShopProduct(this.title, this.description, this.picture, this.price);
  factory ShopProduct.fromJson(Map<String, dynamic> json) {
      return ShopProduct(
         json['title'],
         json['description'],
         json['picture'],
         json['price'],
      );
   }
}

List<ShopProduct> parseProducts(String responseBody) {
   final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
   return parsed.map<ShopProduct>((json) =>ShopProduct.fromJson(json)).toList();
}
Future<List<ShopProduct>> fetchProducts() async {
   final response = await http.get('http://192.168.56.1:8000/product.json');
   if (response.statusCode == 200) {
      return parseProducts(response.body);
   } else {
      throw Exception('Unable to fetch products from the REST API');
   }
}

void main() => runApp(MyApp(products: fetchProducts()));

class MyApp extends StatelessWidget {
   final Future<List<ShopProduct>> products;
   MyApp({Key key, this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
         title: 'Passing Data',
         home: MyHomePage(title: 'Product Navigation demo home page', products: products),
      );
   }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final Future<List<ShopProduct>> products;
  MyHomePage({Key key, this.title, this.products}) : super(key: key);

  // final items = Product.getProducts();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: FutureBuilder<List<ShopProduct>>(
            future: products, builder: (context, snapshot) {
            if (snapshot.hasError)
              print(snapshot.error);
            else {
              return ProductScreen(product: snapshot.data);
            }
            // return the ListView widget :
            return CircularProgressIndicator();
            },
          ),
        )
    );
  }
}



class ProductScreen extends StatelessWidget {
  final List<ShopProduct> product;
  ProductScreen({Key key, @required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product'),
      ),
      body: ListView.builder(
          itemCount: product.length + 1,
          itemBuilder: (context, index) {
            if (index >= 0 && index < product.length) {
              return ListTile(
                title: Text(product[index].title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailScreen(product: product[index]),
                    ),
                  );
                },
              );
            } else {
              return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymentScreen(totalPrice: _totalPrice),
                      ),
                    );
                  },
                  child: Text('Confirm Order'));
            }
          }),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final ShopProduct product;

  DetailScreen({Key key, @required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: BodyLayout(product: product),
    );
  }
}

class BodyLayout extends StatelessWidget {
  int counter = 0;
  final ShopProduct product;

  BodyLayout({Key key, @required this.product}) : super(key: key);
  int productCount = 1;

  @override
  Widget build(BuildContext context) {
    //int productPrice = (product.price) as int;
    return StatefulBuilder(
      builder: (context, StateSetter setState) => Center(
          child: Column(children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            child: Image.asset(product.picture, height: 200, width: 200),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(product.description),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Price: ' + product.price),
        ),
        Container(
            alignment: Alignment.center,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                padding: EdgeInsets.all(45),
              ),
              RaisedButton(
                  onPressed: () {
                    if (productCount > 1) {
                      productCount = productCount - 1;
                    } else {
                      productCount = 1;
                    }
                    print(productCount);
                    setState(() => counter++);
                  },
                  child: Text('-')),
              Container(
                  child: Text(productCount.toString()),
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  )),
              RaisedButton(
                  onPressed: () {
                    productCount = productCount + 1;
                    print(productCount);
                    setState(() => counter++);
                  },
                  child: Text('+')),
            ])),
        Container(
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () {
              _totalPrice = int.parse(product.price) * productCount + _totalPrice;
              print(_totalPrice);
              Navigator.pop(context,_totalPrice);
            },
            child: Text('Add to cart'),
            color: Colors.yellowAccent,
          ),
        ),
      ])),
    );
  }
}

class PaymentScreen extends StatelessWidget{
  int totalPrice;
  PaymentScreen({Key key, @required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotation Screen'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Total Price:'),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('฿' + totalPrice.toString()),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _totalPrice = 0;
                    Navigator.pop(context,totalPrice);
                    print(totalPrice);
                  },
                  child: Text('Confirm Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
