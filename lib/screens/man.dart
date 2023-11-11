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
    "title": "Shop for shirts, tees, jeans, hoodies...",
    "image":
        "https://images.unsplash.com/photo-1519058082700-08a0b56da9b4?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  },
  "Makeup": {
    "title": "Shop the full collection of men’s...",
    "image":
        "https://images.unsplash.com/photo-1504593811423-6dd665756598?crop=entropy&w=840&fit=crop",
    "price": "220"
  },
  "Coffee": {
    "title": "Menswear gets a stylish update...",
    "image":
        "https://images.unsplash.com/photo-1489924309280-34282407eca2?crop=entropy&w=840&h=840&fit=crop",
    "price": "40"
  },
  "Fashion": {
    "title": "Our men's collection focuses on...",
    "image":
        "https://images.unsplash.com/photo-1495605952598-956edca588a4?crop=entropy&w=840&h=840&fit=crop",
    "price": "188"
  },
  "Argon": {
    "title": "From latest styles to classic looks, we have it.",
    "image":
        "https://images.unsplash.com/photo-1505022610485-0249ba5b3675?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  }
};

class Man extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "Man",
          searchBar: true,
          categoryOne: "Categories",
          categoryTwo: "Best Deals",
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: MaterialDrawer(currentPage: "Man"),
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
