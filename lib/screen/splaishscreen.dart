import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task3/saervice/loingscreen.dart';
import 'package:task3/saervice/signup.dart';

class splaishscreen extends StatefulWidget {
  const splaishscreen({super.key});

  @override
  State<splaishscreen> createState() => _splaishscreenState();
}

class _splaishscreenState extends State<splaishscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image(
          image: NetworkImage(
              'https://images.pexels.com/photos/2396220/pexels-photo-2396220.jpeg?auto=compress&cs=tinysrgb&w=600'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
