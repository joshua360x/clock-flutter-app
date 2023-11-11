import 'package:flutter/material.dart';
import 'package:material_kit_pro_flutter/constants/Theme.dart';

//widgets
import 'package:material_kit_pro_flutter/widgets/navbar.dart';

class NotificationsSettings extends StatefulWidget {
  @override
  _NotificationsSettingsState createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  bool switchValueOne;
  bool switchValueTwo;
  bool switchValueThree;
  bool switchValueFour;

  void initState() {
    setState(() {
      switchValueOne = false;
      switchValueTwo = false;
      switchValueThree = false;
      switchValueFour = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: "Notifications Settings",
        backButton: true,
        rightOptions: false,
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text("Recommended Settings",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18)),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("These are the most important settings",
                      style: TextStyle(color: Colors.black, fontSize: 14)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Someone mentions me",
                        style: TextStyle(color: Colors.black)),
                    Switch.adaptive(
                      value: switchValueOne,
                      onChanged: (bool newValue) =>
                          setState(() => switchValueOne = newValue),
                      activeColor: MaterialColors.primary,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Anyone follows me",
                        style: TextStyle(color: Colors.black)),
                    Switch.adaptive(
                      value: switchValueTwo,
                      onChanged: (bool newValue) =>
                          setState(() => switchValueTwo = newValue),
                      activeColor: MaterialColors.primary,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Someone comments me",
                        style: TextStyle(color: Colors.black)),
                    Switch.adaptive(
                      value: switchValueThree,
                      onChanged: (bool newValue) =>
                          setState(() => switchValueThree = newValue),
                      activeColor: MaterialColors.primary,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("A seller follows me",
                        style: TextStyle(color: Colors.black)),
                    Switch.adaptive(
                      value: switchValueFour,
                      onChanged: (bool newValue) =>
                          setState(() => switchValueFour = newValue),
                      activeColor: MaterialColors.primary,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
