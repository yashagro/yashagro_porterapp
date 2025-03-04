import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/baground.png"), // ✅ Background Image
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          /// **Semi-Transparent Overlay**
          Container(
            color: Colors.black.withOpacity(
              0.2,
            ), // ✅ Adjust opacity for darkness
          ),

          /// **Foreground Content**
          Center(child: child),
        ],
      ),
    );
  }
}
