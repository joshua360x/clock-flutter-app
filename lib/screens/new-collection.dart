import 'package:flutter/material.dart';

import 'package:material_kit_pro_flutter/constants/Theme.dart';

//widgets
import 'package:material_kit_pro_flutter/widgets/navbar.dart';
import 'package:material_kit_pro_flutter/widgets/card-horizontal.dart';
import 'package:material_kit_pro_flutter/widgets/card-small.dart';
import 'package:material_kit_pro_flutter/widgets/card-square.dart';
import 'package:material_kit_pro_flutter/widgets/drawer.dart';

// import 'package:material_kit_pro_flutter/screens/product.dart';

final Map<String, Map<String, String>> homeCards = {
  "Ice Cream": {
    "title": "Brand new Autumn gear for every man...",
    "image":
        "https://images.unsplash.com/uploads/14126691796798a85b1b0/970ca552?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  },
  "Makeup": {
    "title": "Bird lovers can enjoy the new collection...",
    "image":
        "https://images.unsplash.com/photo-1513043105799-ba3f53df3ab7?crop=entropy&w=840&fit=crop",
    "price": "220"
  },
  "Coffee": {
    "title": "Pottery brand new courses just for...",
    "image":
        "https://images.unsplash.com/photo-1523263666618-c992b26eec21?crop=entropy&w=840&h=840&fit=crop",
    "price": "40"
  },
  "Fashion": {
    "title": "New Collection of hand-made red paper...",
    "image":
        "https://images.unsplash.com/photo-1543342578-aedb05536855?crop=entropy&w=840&h=840&fit=crop",
    "price": "188"
  },
  "Argon": {
    "title": "Add a trip to Bellagio Hotel to your...",
    "image":
        "https://images.unsplash.com/photo-1543321269-9d86d3680e1c?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  }
};

class NewCollection extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "New Collection",
          searchBar: true,
          categoryOne: "Categories",
          categoryTwo: "Best Deals",
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: MaterialDrawer(currentPage: "New Collection"),
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
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => Product(
                        //         title: homeCards["Ice Cream"]['title'],
                        //         urlImg: homeCards["Ice Cream"]['image'],
                        //       ),
                        //     ));
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
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => Product(
                          //         title: homeCards["Makeup"]['title'],
                          //         urlImg: homeCards["Makeup"]['image'],
                          //       ),
                          //     ));
                        }),
                    CardSmall(
                        cta: "View article",
                        title: homeCards["Coffee"]['title'],
                        img: homeCards["Coffee"]['image'],
                        tap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => Product(
                          //         title: homeCards["Coffee"]['title'],
                          //         urlImg: homeCards["Coffee"]['image'],
                          //       ),
                          //     ));
                        })
                  ],
                ),
                SizedBox(height: 8.0),
                CardHorizontal(
                    cta: "View article",
                    title: homeCards["Fashion"]['title'],
                    img: homeCards["Fashion"]['image'],
                    tap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => Product(
                      //         title: homeCards["Fashion"]['title'],
                      //         urlImg: homeCards["Fashion"]['image'],
                      //       ),
                      //     ));
                    }),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: CardSquare(
                      cta: "View article",
                      title: homeCards["Argon"]['title'],
                      img: homeCards["Argon"]['image'],
                      tap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => Product(
                        //         title: homeCards["Argon"]['title'],
                        //         urlImg: homeCards["Argon"]['image'],
                        //       ),
                        //     ));
                      }),
                )
              ],
            ),
          ),
        ));
  }
}
