// import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:material_kit_pro_flutter/constants/Theme.dart';

//widgets
import 'package:material_kit_pro_flutter/widgets/navbar.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  List<Map<String, String>> messages = [];
  final TextEditingController controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "Rachel Brown",
          backButton: true,
          rightOptions: false,
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ListView(
                    reverse: true,
                    shrinkWrap: true,
                    controller: _scrollController,
                    children: [
                      Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Container(
                                height: 35,
                                width: 35,
                                child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/img/chat-avatar.jpeg"),
                                  radius: 65.0,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 15.0),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                    child: Text(
                                      'Hey there! How are you today? Can we meet and talk? Thanks!',
                                      style: TextStyle(color: Colors.black),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text('10:31 PM',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 11.0)),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 15.0),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              MaterialColors.gradientStart
                                                  .withOpacity(0.9),
                                              MaterialColors.gradientEnd
                                                  .withOpacity(0.9)
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0))),
                                      child: Text(
                                        'Sure, just let me finish something and I ll call\nyou.',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text('10:34 PM',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11.0)),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Container(
                                height: 35,
                                width: 35,
                                child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/img/chat-avatar.jpeg"),
                                  radius: 65.0,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 15.0),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                    child: Text(
                                      'OK. Cool! See you!',
                                      style: TextStyle(color: Colors.black),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text('10:35 PM',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 11.0)),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 15.0),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              MaterialColors.gradientStart
                                                  .withOpacity(0.9),
                                              MaterialColors.gradientEnd
                                                  .withOpacity(0.9)
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0))),
                                      child: Text(
                                        'Bye bye',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text('10:36 PM',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11.0)),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        for (var i = 0; i < messages.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 15.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  MaterialColors.gradientStart
                                                      .withOpacity(0.9),
                                                  MaterialColors.gradientEnd
                                                      .withOpacity(0.9)
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0))),
                                          child: Text(
                                            messages[i]['body'],
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(messages[i]['time'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 11.0)),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                      ]),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {},
                      )),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 3,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: TextField(
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              setState(() {
                                messages.add({
                                  "body": value,
                                  "time": "10:40 PM",
                                  "author_image":
                                      "assets/img/profile-screen-avatar.jpg"
                                });
                              });
                              _scrollController.animateTo(
                                0.0,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                              controller.text = "";
                            },
                            controller: controller,
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Message',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 15.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
