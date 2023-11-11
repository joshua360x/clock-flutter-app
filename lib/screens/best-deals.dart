import 'package:flutter/material.dart';

import 'package:material_kit_pro_flutter/constants/Theme.dart';
import 'package:material_kit_pro_flutter/constants/Images.dart';

//widgets
import 'package:material_kit_pro_flutter/widgets/navbar.dart';
import 'package:material_kit_pro_flutter/widgets/card-horizontal.dart';
import 'package:material_kit_pro_flutter/widgets/card-small.dart';
import 'package:material_kit_pro_flutter/widgets/card-square.dart';

import 'package:material_kit_pro_flutter/screens/product.dart';

final Map<String, List<Map>> dealsCards = {
  "POPULAR": [
    {
      "title": "We'll start with the basics and go...",
      "image": images["deals"]["We'll start with the basics and go..."],
      "price": ""
    },
    {
      "title": 'Give your skincare routine a boost...',
      "image": images["deals"]["Give your skincare routine a boost..."],
      "price": ""
    },
    {
      "title": 'The gaming version of an action movie...',
      "image": images["deals"]["The gaming version of an action movie..."],
      "price": ""
    },
    {
      "title": 'Whether you’re tearing up the track...',
      "image": images["deals"]["Whether you’re tearing up the track..."],
      "price": ""
    },
    {
      "title": 'Harley-Davidson Motorcycle has...',
      "image": images["deals"]["Harley-Davidson Motorcycle has..."],
      "price": ""
    },
  ],
  "BEAUTY": [
    {"title": 'Brushes', "image": images["deals"]["Brushes"], "price": ""},
    {
      "title": 'Pink Lipstick',
      "image": images["deals"]["Pink Lipstick"],
      "price": ""
    },
    {"title": 'Skin Care', "image": images["deals"]["Skin Care"], "price": ""},
    {
      "title": 'Curious Blossom Skin Care Kit.',
      "image": images["deals"]["Curious Blossom Skin Care Kit."],
      "price": ""
    },
    {
      "title": 'Buy the best skin care products.',
      "image": images["deals"]["Buy the best skin care products."],
      "price": ""
    },
  ],
  "CARS": [
    {"title": 'Dream Car', "image": images["deals"]["Dream Car"], "price": ""},
    {
      "title": 'Smart Mobility',
      "image": images["deals"]["Smart Mobility"],
      "price": ""
    },
    {
      "title": 'Need for Speed',
      "image": images["deals"]["Need for Speed"],
      "price": ""
    },
    {
      "title": 'The gaming version of an action movie...',
      "image": images["deals"]["The gaming version of an action movie..."],
      "price": ""
    },
    {
      "title": 'What’s so special about Le Mans?',
      "image": images["deals"]["What’s so special about Le Mans?"],
      "price": ""
    },
  ],
  "MOTORCYCLE": [
    {
      "title": 'Learn to Ride',
      "image": images["deals"]["Learn to Ride"],
      "price": ""
    },
    {"title": 'Test Ride', "image": images["deals"]["Test Ride"], "price": ""},
    {
      "title": 'Parts & Apparel',
      "image": images["deals"]["Parts & Apparel"],
      "price": ""
    },
    {
      "title": 'Harley-Davidson Motorcycle has...',
      "image": images["deals"]["Harley-Davidson Motorcycle has..."],
      "price": ""
    },
    {
      "title": 'We\'ll start with the basics and go...',
      "image": images["deals"]["We'll start with the basics and go..."],
      "price": ""
    },
  ],
};

final List<String> tags = ["POPULAR", "BEAUTY", "CARS", "MOTORCYCLE"];

class BestDeals extends StatefulWidget {
  @override
  _BestDealsState createState() => _BestDealsState();
}

class _BestDealsState extends State<BestDeals> {
  static String currentTag;

  _getCurrentPage(activeTag) {
    setState(() {
      currentTag = activeTag;
      print('currentTag is $currentTag');
    });
  }

  void initState() {
    currentTag = tags[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "Best Deals",
          tags: tags,
          getCurrentPage: _getCurrentPage,
          backButton: true,
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        body: Container(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CardHorizontal(
                        cta: "View article",
                        title: dealsCards[currentTag][0]['title'],
                        img: dealsCards[currentTag][0]['image'],
                        tap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Product(
                                  title: dealsCards[currentTag][0]['title'],
                                  urlImg: dealsCards[currentTag][0]['image'],
                                ),
                              ));
                        }),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      CardSmall(
                          cta: "View article",
                          title: dealsCards[currentTag][1]['title'],
                          img: dealsCards[currentTag][1]['image'],
                          tap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Product(
                                    title: dealsCards[currentTag][1]['title'],
                                    urlImg: dealsCards[currentTag][1]['image'],
                                  ),
                                ));
                          }),
                      CardSmall(
                          cta: "View article",
                          title: dealsCards[currentTag][2]['title'],
                          img: dealsCards[currentTag][2]['image'],
                          tap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Product(
                                    title: dealsCards[currentTag][2]['title'],
                                    urlImg: dealsCards[currentTag][2]['image'],
                                  ),
                                ));
                          })
                    ],
                  ),
                  SizedBox(height: 8.0),
                  CardHorizontal(
                      cta: "View article",
                      title: dealsCards[currentTag][3]['title'],
                      img: dealsCards[currentTag][3]['image'],
                      tap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Product(
                                title: dealsCards[currentTag][3]['title'],
                                urlImg: dealsCards[currentTag][3]['image'],
                              ),
                            ));
                      }),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: CardSquare(
                        cta: "View article",
                        title: dealsCards[currentTag][4]['title'],
                        img: dealsCards[currentTag][4]['image'],
                        tap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Product(
                                  title: dealsCards[currentTag][4]['title'],
                                  urlImg: dealsCards[currentTag][4]['image'],
                                ),
                              ));
                        }),
                  )
                ],
              ),
            )));
  }
}
