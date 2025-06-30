import 'package:flutter/material.dart';

import '../Theme/Theme.dart';
import 'TextWidget.dart';

class Buttoncustom extends StatelessWidget {
  const Buttoncustom({
    super.key,
    required this.text,
    this.size = 16,
    required this.onTap,
    });

  final String text;
  final double size;
  final Function onTap;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await onTap();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Textwidget(text: text, color: Colors.white, size: size,)
        ), 
      ),
    );
  }
}