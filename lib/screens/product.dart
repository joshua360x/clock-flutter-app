import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_kit_pro_flutter/constants/Theme.dart';

//widgets
import 'package:material_kit_pro_flutter/widgets/navbar.dart';
import 'package:material_kit_pro_flutter/widgets/slider.dart';
import 'package:material_kit_pro_flutter/widgets/product-size-picker.dart';
import 'package:material_kit_pro_flutter/screens/chat.dart';

class Product extends StatelessWidget {
  final double height = window.physicalSize.height;
  final String urlImg;
  final String title;

  Product(
      {this.title = "Shoes", this.urlImg = "https://via.placeholder.com/250"});

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [urlImg, urlImg];
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: Navbar(
          title: "",
          transparent: true,
          backButton: true,
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        body: Stack(children: [
          Container(
              height: 0.2 * height, child: ImageSlider(imgArray: imgList)),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 8,
                            blurRadius: 10,
                            offset: Offset(0, 0))
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(13.0),
                        topRight: Radius.circular(13.0),
                      )),
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.56,
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Stack(children: [
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        child: SafeArea(
                          bottom: true,
                          top: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 82.0),
                                child: Text(title,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            "https://images.unsplash.com/photo-1512529920731-e8abaea917a5?fit=crop&w=840&q=80"),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Rachel Brown",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text("Pro Seller",
                                                style: TextStyle(
                                                    color:
                                                        MaterialColors.muted)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text("735\$",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16))
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Size",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500))),
                              ),
                              ProductSizePicker(),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: RaisedButton(
                                    onPressed: () {},
                                    textColor: Colors.white,
                                    color: MaterialColors.primary,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16.0),
                                    child: Text("ADD TO CART",
                                        style: TextStyle(fontSize: 16))),
                              )
                            ],
                          ),
                        )),
                    FractionalTranslation(
                      translation: Offset(-0.04, -0.08),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: MaterialColors.primary,
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat()));
                            },
                            icon: Icon(Icons.message),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ])))
        ]));
  }
}
