import 'package:flutter/material.dart';

class ZappisLogo extends StatelessWidget {
  final double size;
  final Color? color;
  
  const ZappisLogo({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).primaryColor;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bolt,
          color: logoColor,
          size: size,
        ),
        Text(
          'ZAPPIS',
          style: TextStyle(
            fontFamily: 'Magnetico',
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: logoColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
