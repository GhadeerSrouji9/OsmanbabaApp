

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          // STACK AND MAIN COLUMN
          child: Column(
            children: [
              Container(
                height: 200,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0.0,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.orange,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 150.0,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 100,
                      child: Container(
                        height: 100,
                        child: Image.asset("assets/imgs/logo1.png"),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 32.0,
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              "Username",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              "Company name",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // CONTACT INFO
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: Text(
                  "Contact info:",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
//                color: Colors.red,
                margin: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "www.site.com",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.orange,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "email@gmail.com",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.orange,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              "personal No",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,

                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "Company No",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.orange,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // SOCIAL MEDIA ROW
              Container(
                margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // FACEBOOK
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              "Faceusername",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: Image.asset(
                              "assets/imgs/facebook.png",
                            ),
                          ),
                        ],
                      ),
                    ),
                    // INSTAGRAM
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              "Instausername",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: Image.asset(
                              "assets/imgs/instagram.png",
                            ),
                          ),
                        ],
                      ),
                    ),
                    // TWITTER
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              "Twitterusername",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: Image.asset(
                              "assets/imgs/twitter.png",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // LICENSES
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  "Licenses:",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 1. LICENSE
                    Column(
                      children: [
                        Container(
                          child: Text(
                            "Work License",
                            style: TextStyle(
                              color: Colors.orange
                            ),
                          ),
                        ),
                        Container(
                          height: 100,
                          child: Image.asset("assets/imgs/logo1.png"),
                        )
                      ],
                    ),
                    // 2. LICENSE
                    Column(
                      children: [
                        Container(
                          child: Text(
                            "Industrial License",
                            style: TextStyle(
                                color: Colors.orange
                            ),
                          ),
                        ),
                        Container(
                          height: 100,
                          child: Image.asset("assets/imgs/logo1.png"),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

}