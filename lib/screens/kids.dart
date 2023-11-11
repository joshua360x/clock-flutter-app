import 'package:flutter/material.dart';

import 'package:material_kit_pro_flutter/constants/Theme.dart';

//widgets
import 'package:material_kit_pro_flutter/widgets/navbar.dart';
import 'package:material_kit_pro_flutter/widgets/card-horizontal.dart';
import 'package:material_kit_pro_flutter/widgets/card-small.dart';
import 'package:material_kit_pro_flutter/widgets/card-square.dart';
import 'package:material_kit_pro_flutter/widgets/drawer.dart';

import 'package:material_kit_pro_flutter/screens/product.dart';

final Map<String, Map<String, String>> homeCards = {
  "Ice Cream": {
    "title": "Enjoy your every moment of a pillow fight.",
    "image":
        "https://images.unsplash.com/photo-1513807016779-d51c0c026263?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  },
  "Makeup": {
    "title": "Everyone is a superhero in their hearts.",
    "image":
        "https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?crop=entropy&w=840&fit=crop",
    "price": "220"
  },
  "Coffee": {
    "title": "Yes, I’m a Princess and I like the color Red.",
    "image":
        "https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?crop=entropy&w=840&h=840&fit=crop",
    "price": "40"
  },
  "Fashion": {
    "title": "This was the best ice cream I had last summer.",
    "image":
        "https://images.unsplash.com/photo-1502901930015-158e72cff877?crop=entropy&w=840&h=840&fit=crop",
    "price": "188"
  },
  "Argon": {
    "title": "This world is full of hope. Make the most of it!",
    "image":
        "https://images.unsplash.com/photo-1489710437720-ebb67ec84dd2?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  }
};

class Kids extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "Kids",
          searchBar: true,
          categoryOne: "Categories",
          categoryTwo: "Best Deals",
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: MaterialDrawer(currentPage: "Kids"),
        body: Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CardHorizontal(
                      cta: "View article",
                      title: homeCards["Ice Cream"]['title'],
                      img: homeCards["Ice Cream"]['image'],
                      tap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Product(
                                title: homeCards["Ice Cream"]['title'],
                                urlImg: homeCards["Ice Cream"]['image'],
                              ),
                            ));
                      }),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CardSmall(
                        cta: "View article",
                        title: homeCards["Makeup"]['title'],
                        img: homeCards["Makeup"]['image'],
                        tap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Product(
                                  title: homeCards["Makeup"]['title'],
                                  urlImg: homeCards["Makeup"]['image'],
                                ),
                              ));
                        }),
                    CardSmall(
                        cta: "View article",
                        title: homeCards["Coffee"]['title'],
                        img: homeCards["Coffee"]['image'],
                        tap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Product(
                                  title: homeCards["Coffee"]['title'],
                                  urlImg: homeCards["Coffee"]['image'],
                                ),
                              ));
                        })
                  ],
                ),
                SizedBox(height: 8.0),
                CardHorizontal(
                    cta: "View article",
                    title: homeCards["Fashion"]['title'],
                    img: homeCards["Fashion"]['image'],
                    tap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Product(
                              title: homeCards["Fashion"]['title'],
                              urlImg: homeCards["Fashion"]['image'],
                            ),
                          ));
                    }),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: CardSquare(
                      cta: "View article",
                      title: homeCards["Argon"]['title'],
                      img: homeCards["Argon"]['image'],
                      tap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Product(
                                title: homeCards["Argon"]['title'],
                                urlImg: homeCards["Argon"]['image'],
                              ),
                            ));
                      }),
                )
              ],
            ),
          ),
        ));
  }
}
