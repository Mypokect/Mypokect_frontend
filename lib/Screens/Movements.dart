import 'package:MyPocket/Theme/Theme.dart';
import 'package:MyPocket/Widgets/TextWidget.dart';
import 'package:MyPocket/Widgets/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

class Movements extends StatefulWidget {
  const Movements({super.key});

  @override
  State<Movements> createState() => _MovementsState();
}

class _MovementsState extends State<Movements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.only(left: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Textwidget(text: 'Dale un nombre a tu movimiento 💵', size: 35, color: Colors.black, fontWeight: FontWeight.w500, maxLines: 2,),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                decoration: InputDecoration(
                  icon: Text('🏷  ', style: TextStyle(fontSize: 20,)),
                  hintText: 'Ej. Compra del hogar',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 20, fontFamily: 'Baloo2'),
                  border: InputBorder.none  
                ),
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                decoration: InputDecoration(
                  icon: Text('💰  ', style: TextStyle(fontSize: 20,)),
                  hintText: 'Ej. \$15.000',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 20, fontFamily: 'Baloo2'),
                  border: InputBorder.none  
                ),
              )
            ),
            SizedBox(height: 20),
            AnimatedToggleSwitch(),
            SizedBox(height: 100),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.grey[500], size: 20),
                      Textwidget(text: 'Agrega una nueva transacción', size: 14, color: Colors.grey[500]!, fontWeight: FontWeight.w500, maxLines: 2,),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        offset: const Offset(0, 6),
                        blurRadius: 20,
                      ),
                    ]
                    ),
                    child: Icon(Icons.mic_none_rounded, color: Colors.white, size: 40,),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}