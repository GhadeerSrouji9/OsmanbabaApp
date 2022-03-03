

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Animate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AnimateState();
  }

}

class _AnimateState extends State<Animate> with SingleTickerProviderStateMixin{

  AnimationController _controller;
  Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..forward();
    _animation = Tween<Offset>(
      begin: const Offset(0, 0.0),
      end: const Offset(2, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SlideTransition(
          position: _animation,

          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: FlutterLogo(size: 150.0),
          ),
        )
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}