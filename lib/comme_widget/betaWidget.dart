import 'package:flutter/material.dart';

class Betawidget extends StatelessWidget {
  const Betawidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.topLeft,
      child: const SizedBox(
        height: 40,
        width: 80,
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Center(
            child: Text(
              "Beta",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
