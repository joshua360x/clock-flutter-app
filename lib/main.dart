import 'package:flutter/material.dart';

// screens
import 'package:material_kit_pro_flutter/screens/home.dart';
import 'package:material_kit_pro_flutter/screens/woman.dart';
import 'package:material_kit_pro_flutter/screens/man.dart';
import 'package:material_kit_pro_flutter/screens/kids.dart';
import 'package:material_kit_pro_flutter/screens/new-collection.dart';
import 'package:material_kit_pro_flutter/screens/profile.dart';
import 'package:material_kit_pro_flutter/screens/settings.dart';
import 'package:material_kit_pro_flutter/screens/components.dart';
import 'package:material_kit_pro_flutter/screens/onboarding.dart';
import 'package:material_kit_pro_flutter/screens/signin.dart';
import 'package:material_kit_pro_flutter/screens/signup.dart';

void main() => runApp(MaterialKitPROFlutter());

class MaterialKitPROFlutter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Material Kit PRO Flutter",
        debugShowCheckedModeBanner: false,
        initialRoute: "/onboarding",
        routes: <String, WidgetBuilder>{
          "/onboarding": (BuildContext context) => new Onboarding(),
          "/home": (BuildContext context) => new Home(),
          "/woman": (BuildContext context) => new Woman(),
          "/man": (BuildContext context) => new Man(),
          "/kids": (BuildContext context) => new Kids(),
          "/components": (BuildContext context) => new Components(),
          "/newcollection": (BuildContext context) => new NewCollection(),
          "/profile": (BuildContext context) => new Profile(),
          "/settings": (BuildContext context) => new Settings(),
          "/signin": (BuildContext context) => new SignIn(),
          "/signup": (BuildContext context) => new SignUp(),
        });
  }
}
