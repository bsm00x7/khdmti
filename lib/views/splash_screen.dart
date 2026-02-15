import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:khdmti_project/utils/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

void next() {}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the timer when the widget initializes
    Timer(const Duration(seconds: 2), () {
      // Navigate using GoRouter — the redirect logic will check auth state
      // and send to /loginScreen if not authenticated
      if (mounted) {
        context.go('/ButtomNav');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            transform: GradientRotation(3),
            tileMode: TileMode.clamp,
            stops: [0, 0.4, 1],
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
            colors: [Color(0xFF0d1f2d), Color(0xFF1a3a52), Color(0xFF1a3a52)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.24),
              SizedBox(
                height: size.width * 0.4,
                width: size.width * 0.4,
                child: SvgPicture.asset(
                  Assets.logoSplashScreen,
                  semanticsLabel: "Logo",
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "خدمتي",
                style: TextStyle(
                  fontSize: 60,
                  fontStyle: FontStyle.normal,
                  textBaseline: TextBaseline.alphabetic,
                  fontFamily: "Inter",
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "KHIDMATI",
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.normal,
                  textBaseline: TextBaseline.alphabetic,
                  fontFamily: "Inter",
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 9,
                ),
              ),
              const Text(
                "Connecting Talent in Tunisia",
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.normal,
                  textBaseline: TextBaseline.alphabetic,
                  fontFamily: "Inter",
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                ),
              ),
              SizedBox(height: size.width * 0.4),
              SizedBox(
                height: 14,
                width: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(width: 8);
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Version 1.0",
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.normal,
                  textBaseline: TextBaseline.alphabetic,
                  fontFamily: "Inter",
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
