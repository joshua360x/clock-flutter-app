import 'package:flutter/material.dart';
import 'package:material_kit_pro_flutter/constants/Theme.dart';

//widgets
import 'package:material_kit_pro_flutter/widgets/navbar.dart';
import 'package:material_kit_pro_flutter/widgets/slider-product.dart';
import 'package:material_kit_pro_flutter/widgets/card-small.dart';

import 'package:material_kit_pro_flutter/screens/product.dart';

class Category extends StatelessWidget {
  final String screenTitle;
  final List imgArray;
  final List suggestionsArray;

  Category(
      {this.screenTitle = "Category", this.imgArray, this.suggestionsArray});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: screenTitle,
          backButton: true,
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        body: SingleChildScrollView(
          child: Container(
              child: Column(
            children: [
              Container(
                // height: 700,
                padding: EdgeInsets.only(top: 16.0),
                child: ProductCarousel(imgArray: imgArray),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CardSmall(
                        img: suggestionsArray[0]["img"],
                        title: suggestionsArray[0]["title"],
                        tap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Product(
                                  title: suggestionsArray[0]['title'],
                                  urlImg: suggestionsArray[0]['img'],
                                ),
                              ));
                        }),
                    CardSmall(
                        img: suggestionsArray[1]["img"],
                        title: suggestionsArray[1]["title"],
                        tap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Product(
                                  title: suggestionsArray[1]['title'],
                                  urlImg: suggestionsArray[1]['img'],
                                ),
                              ));
                        }),
                  ],
                ),
              )
            ],
          )),
        ));
  }
}
