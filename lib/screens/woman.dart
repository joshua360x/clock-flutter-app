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
    "title": "Affordable ladies fashion for every occasion.",
    "image":
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  },
  "Makeup": {
    "title": "Shop current season to classic in our...",
    "image":
        "https://images.unsplash.com/photo-1542838686-b08706f6f2d1?crop=entropy&w=840&fit=crop",
    "price": "220"
  },
  "Coffee": {
    "title": "Stand out from the crowd with the...",
    "image":
        "https://images.unsplash.com/photo-1503066375319-00fef06b159e?crop=entropy&w=840&h=840&fit=crop",
    "price": "40"
  },
  "Fashion": {
    "title": "Women's sport sometimes seems to...",
    "image":
        "https://images.unsplash.com/photo-1445384763658-0400939829cd?crop=entropy&w=840&h=840&fit=crop",
    "price": "188"
  },
  "Argon": {
    "title": "The Glamour Awards is an annual...",
    "image":
        "https://images.unsplash.com/photo-1499313843378-eebdb187f629?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  }
};

class Woman extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "Woman",
          searchBar: true,
          categoryOne: "Categories",
          categoryTwo: "Best Deals",
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: MaterialDrawer(currentPage: "Woman"),
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
