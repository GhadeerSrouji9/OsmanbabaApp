
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:osmanbaba/helpers/app_localization.dart';
import 'package:osmanbaba/pages/product.dart';

class ads extends StatefulWidget {
  Map <String ,dynamic> top4ads;
  bool isLoading ;
  ads(this.top4ads,this.isLoading);
  @override
  _adsState createState() => _adsState();
}

class _adsState extends State<ads> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async{
        if(!widget.isLoading) {
          Navigator.push(
              this.context,

              new MaterialPageRoute(builder: (context) => new Product(widget.top4ads["id"], widget.top4ads["primaryImage"] ))

          );
        } else {
          Fluttertoast.showToast(
              msg: Localizations.of<AppLocalizations>(context, AppLocalizations).getTranslation('toastWaitWhileLoading'),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white70,
              textColor: Colors.black,
              fontSize: 16.0
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width * 0.50,
        padding: EdgeInsets.only(bottom: (MediaQuery.of(context).size.height * 0.02)),
        child: Stack(
          children: [
            /*LOGO*/
            Positioned(
              left: MediaQuery.of(context).size.width*0.028,
              top: MediaQuery.of(context).size.height*0.002,
              child: Container(
                height: MediaQuery.of(context).size.height*0.06,
                width: MediaQuery.of(context).size.width * 0.13,
                child: ClipPath(
                  clipper: _LogoClipper(),
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.20,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        border: Border.all(width: 1.5, color: Colors.orange)
                    ),
                    child: ClipPath(
                      clipper: _LogoClipper(),
                      child: Container(
                          width: 100,
                          height: 75,
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 0.5, color: Colors.orange)
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.top4ads.isNotEmpty ? widget.top4ads["logo"] :
                            "https://i.pinimg.com/originals/f9/11/d3/f911d38579709636499618b6b3d9b6f6.jpg",
                            placeholder: (context, url) => Center(
                              child: Container(
                                width: 30,
                                height: 30,
                               // child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return Center(child: Container(child: Image.asset('assets/imgs/error/imageLoadFailure.png')));
                            },
                          )
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // MACHINE
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: MediaQuery.of(context).size.height*0.2,
                width: MediaQuery.of(context).size.width * 0.45,
                padding: EdgeInsets.all(4.0),
                child: ClipPath(
                  clipper: _AdClipper(),
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.75,
                    height: MediaQuery.of(context).size.height*0.3,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)
                        ),
                        color: Colors.orange,
                        border: Border.all(width: 0, color: Colors.transparent)
                    ),
                    child: ClipPath(
                      clipper: _AdClipper(),
                      child: Container(
                        margin: EdgeInsets.all(2),
                        width: MediaQuery.of(context).size.width*0.75,
                        height: MediaQuery.of(context).size.height*0.3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.top4ads.isNotEmpty ? widget.top4ads["primaryImage"] :
                          "https://i.pinimg.com/originals/f9/11/d3/f911d38579709636499618b6b3d9b6f6.jpg",
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Center(
                            child: Container(
                              width: MediaQuery.of(context).size.height*0.05,
                              height: MediaQuery.of(context).size.height*0.05,
                             // child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return Center(child: Container(child: Image.asset('assets/imgs/error/imageLoadFailure.png')));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // PRODUCT
            Positioned(
              top: MediaQuery.of(context).size.height*0.15,
              right: MediaQuery.of(context).size.width*0.025,
              child: Container(
                height: 40,
                width: 50,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)
                    ),
                    color: Colors.white,
                    border: Border.all(width: 1.5, color: Colors.orange)
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.top4ads.isNotEmpty ? widget.top4ads["productImage"] :
                  "https://i.pinimg.com/originals/f9/11/d3/f911d38579709636499618b6b3d9b6f6.jpg",
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Center(
                    child: Container(
                      width: 30,
                      height: 30,
                     // child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Center(child: Container(child: Image.asset('assets/imgs/error/imageLoadFailure.png')));
                  },
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }
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
