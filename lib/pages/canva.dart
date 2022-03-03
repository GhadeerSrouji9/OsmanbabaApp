import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/helpers/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Canva extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _CanvaState();
  }
}

class _CanvaState extends State<Canva> {
  final _advancedDrawerController = AdvancedDrawerController();

  var langMap = {'en': 'US', 'ar': 'SAR', 'tr': 'TR'};
  List<Image> flagImages = [Image.asset('icons/flags/png/gb.png', package: 'country_icons'), Image.asset('assets/imgs/sy.jpg'), Image.asset('assets/imgs/tr.jpg')];


  Future<void> storeLanguagePreference(val) async {
    print('___SECOND storeLanguagePreference: val: ' + val + ' ' + langMap[val]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globalLocale = Locale(val, langMap[val]);

    print('___SECOND storeLanguagePreference: Glocale: ' +
        globalLocale.languageCode.toString() + ' ' +
        globalLocale.countryCode.toString());

    await prefs.setString('languageCode', globalLocale.languageCode);
    await prefs.setString('countryCode', globalLocale.countryCode);
    await prefs.setBool('isLanguageSpecified', true);
  }

  int fetchFlagImage (String countryCode){
    switch(countryCode) {
      case 'en':
        return 0;
        break;
      case 'ar':
        return 1;
        break;
      case 'tr':
        return 2;
        break;
    }
    return 99;
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Color.fromRGBO(242, 242, 242, 1),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        // NOTICE: Uncomment if you want to add shadow behind the page.
        // Keep in mind that it may cause animation jerks.
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 0.0,
        //   ),
        // ],
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Drawer Example'),
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
        ),
        body: Container(),
      ),
      drawer: SafeArea(
        child: Container(
          child: ListTileTheme(
            textColor: Colors.orange,
            iconColor: Colors.orange,
            child: Container(
              // decoration: BoxDecoration(border: Border.all()),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 158.0,
                    margin: const EdgeInsets.only(
                      top: 24.0,
                      bottom: 64.0,
                      left: 24.0
                    ),
                    child: Container(
                      child: Image.asset(
                        'assets/imgs/osmanbody_splash.png',
                        width: 128.0,
                        height: 158.0,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: Icon(Icons.category),
                    title: Text('Categories'),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: Icon(Icons.account_circle_rounded),
                    title: Text('Profile'),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: Image.asset("assets/imgs/percent.png", height: 22,),

                    title: Text('Packages'),
                  ),
                  false ?
                  ListTile(
                    onTap: () {},
                    leading: Icon(Icons.settings),
                    title: Text('Login'),
                  ):
                  ListTile(
                    onTap: () {},
                    leading: Icon(Icons.logout),
                    title: Text('Sign out'),
                  ),
                  // FLAGS
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 16.0),
                        child: Icon(Icons.language, color: Colors.orange,),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 32),
                        child: DropdownButton<String>(
                          value: Localizations.of<AppLocalizations>(context, AppLocalizations).locale.languageCode,
//                          value: globalLocale.languageCode,//Localizations.localeOf(context),
                          iconSize: 24,
                          // icon: Visibility (visible: false, child: Icon(Icons.arrow_downward)),
                          elevation: 16,
                          style: const TextStyle(color: Colors.orange),
                          onChanged: (String newValue) {
                            // Gonna use this onChanged listener to change icon
                            setState(() async{
                              await storeLanguagePreference(newValue);
                              isLanguageSpecified = true;
                              Phoenix.rebirth(this.context);
                            });

                          },
                          items: <String>['en', 'ar', 'tr'].map<DropdownMenuItem<String>>((String value) { return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Container(
                                height: 20.0,
                                child: Text(value), //flagImages[fetchFlagImage(value)]
                              ),
                            ),
                          );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  Spacer(),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 16.0,
                      ),
                      child: Text('Terms of Service | Privacy Policy'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

}


class _CustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double heightDelta = size.height / 2.2;

    double radius = 40;

    return Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width, 0)
//      ..arcToPoint(Offset(size.width, 0))
      ..lineTo(size.width, size.height - radius)
      ..arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius))
      ..lineTo(radius, size.height)
      ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius), clockwise: false)
      ..lineTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.elliptical(40, 20))

      ..close();
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _AdClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double heightDelta = size.height / 2.2;

    double radius = 40;
    double withinRadius = 20;
    double edgeRadius = 10;
    double edgeWideRadius = 25;

    return Path()
      ..moveTo(size.width, edgeWideRadius)
    // Bottom left
      ..lineTo(size.width, size.height - edgeWideRadius)
      ..arcToPoint(Offset(size.width - edgeWideRadius, size.height), radius: Radius.circular(edgeWideRadius), clockwise: true)
      ..lineTo(edgeWideRadius, size.height)

      ..arcToPoint(Offset(0, size.height - edgeWideRadius), radius: Radius.circular(edgeWideRadius), clockwise: true)
      ..lineTo(0, size.height / 3)
//      ..arcToPoint(Offset(edgeRadius, size.height / 3), radius: Radius.circular(edgeRadius), clockwise: true)
      ..lineTo(size.width / 3 - withinRadius, size.height / 3)
      ..arcToPoint(Offset(size.width / 3, size.height / 3 - withinRadius), radius: Radius.circular(withinRadius), clockwise: false)
      ..lineTo(size.width / 3, 0)
//      ..arcToPoint(Offset(size.width / 3 + edgeRadius, 0), radius: Radius.circular(withinRadius), clockwise: true)
      ..lineTo(size.width, 0)
      ..arcToPoint(Offset(size.width, edgeWideRadius), radius: Radius.circular(edgeWideRadius), clockwise: true)

//      ..arcToPoint(Offset(100, 0), radius: Radius.circular(100), clockwise: false)
//      ..lineTo(0, 0)
//      ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius), clockwise: false)
//      ..lineTo(0, radius)
//      ..arcToPoint(Offset(radius, 0), radius: Radius.elliptical(40, 20))
      ..close();


  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _LogoClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final double heightDelta = size.height / 2.2;

    double radius = 40;
    double withinRadius = 20;
    double edgeRadius = 10;
    double edgeWideRadius = 30;

    return Path()
      ..moveTo(size.width, 0)
    // Bottom left
      ..lineTo(size.width, size.height - 15)
      ..arcToPoint(Offset(size.width - 15, size.height), radius: Radius.circular(15), clockwise: true)
      ..lineTo(0, size.height)
      ..lineTo(0, edgeWideRadius)
      ..arcToPoint(Offset(edgeWideRadius, 0), radius: Radius.circular(edgeWideRadius), clockwise: true)

//      ..arcToPoint(Offset(size.width, edgeWideRadius), radius: Radius.circular(edgeWideRadius), clockwise: true)
//      ..arcToPoint(Offset(100, 0), radius: Radius.circular(100), clockwise: false)
//      ..lineTo(0, 0)
//      ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius), clockwise: false)
//      ..lineTo(0, radius)
//      ..arcToPoint(Offset(radius, 0), radius: Radius.elliptical(40, 20))
      ..close();


  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}


class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final arc1 = Path();
    arc1.moveTo(size.width * 2.0, size.height * 0.2);
    arc1.arcToPoint(
      Offset(size.width * 0.0, size.height * 0.0),
      radius: Radius.circular(150),
      clockwise: false,
    );

    canvas.drawPath(arc1, paint);


    final arc2 = Path();
    arc2.moveTo(size.width * 0.2, size.height * 0.8);
    arc2.arcToPoint(
      Offset(size.width * 0.8, size.height * 0.8),
      radius: Radius.circular(150),
    );

    canvas.drawPath(arc2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}