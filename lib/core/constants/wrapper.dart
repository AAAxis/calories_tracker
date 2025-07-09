import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff898989),
            Color(0xffECEBE8),
            Color(0xffFAF9F6),
            Color(0xffFAF9F6),
          ],
        ),
      ),
      child: child,
    );
  }
}
