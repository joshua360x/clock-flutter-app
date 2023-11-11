import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:material_kit_pro_flutter/constants/Theme.dart';

import 'package:material_kit_pro_flutter/widgets/drawer.dart';
import 'package:material_kit_pro_flutter/widgets/navbar.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MaterialColors.bgColorScreen,
        drawer: MaterialDrawer(currentPage: "Sign In"),
        extendBodyBehindAppBar: true,
        appBar: Navbar(
          title: "Sign In",
          transparent: true,
        ),
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              MaterialColors.signStartGradient,
              MaterialColors.signEndGradient
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22.0, vertical: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            onPressed: () {},
                            elevation: 4.0,
                            fillColor: MaterialColors.socialFacebook,
                            child: Icon(FontAwesomeIcons.facebook,
                                size: 24.0, color: Colors.white),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          ),
                          RawMaterialButton(
                            onPressed: () {},
                            elevation: 4.0,
                            fillColor: MaterialColors.socialTwitter,
                            child: Icon(FontAwesomeIcons.twitter,
                                size: 24.0, color: Colors.white),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          ),
                          RawMaterialButton(
                            onPressed: () {},
                            elevation: 4.0,
                            fillColor: MaterialColors.socialDribbble,
                            child: Icon(FontAwesomeIcons.dribbble,
                                size: 24.0, color: Colors.white),
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Text("or be classical",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16)),
                    ),
                    Theme(
                      data: ThemeData(
                          primaryColor: Colors.white,
                          accentColor: Colors.white,
                          hintColor: MaterialColors.muted),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: "Username",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Theme(
                        data: ThemeData(
                            primaryColor: Colors.white,
                            accentColor: Colors.white,
                            hintColor: MaterialColors.muted),
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Email",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 8),
                      child: Theme(
                        data: ThemeData(
                            primaryColor: Colors.white,
                            accentColor: Colors.white,
                            hintColor: MaterialColors.muted),
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "Password",
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: RaisedButton(
                            elevation: 4.0,
                            onPressed: () {},
                            textColor: Colors.white,
                            color: MaterialColors.primary,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16.0),
                            child: Text("SIGN IN",
                                style: TextStyle(fontSize: 16))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: FlatButton(
                          child: Text("Already have an account? Sign up"),
                          textColor: Colors.white.withOpacity(0.6),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          }),
                    )
                  ],
                ),
              ),
            )));
  }
}
