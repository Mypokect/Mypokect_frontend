import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Screens/home.dart';
import 'Theme/Theme.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {

  int _currentIndex = 0;
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(),
      body: Center(
        child: IndexedStack(
          index: _currentIndex,
          children: <Widget>[
            Home(),
            Center(child: Text('Pantalla de ajustes')),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: Colors.white,
      currentIndex: _currentIndex,
      onTap: (value) {
        setState(() {
          _currentIndex = value;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/home.svg', color: _currentIndex == 0 ? AppTheme.primaryColor : Colors.grey, width: 26,),
          backgroundColor: Colors.white,
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/wallet.svg', color: _currentIndex == 1 ? AppTheme.primaryColor : Colors.grey, width: 26,),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            child: Icon(Icons.add, color: Colors.white),
          ),
          activeIcon: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            child: Icon(Icons.add, color: AppTheme.secondaryColor),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/flag.svg', color: _currentIndex == 3 ? AppTheme.primaryColor : Colors.grey, width: 26,),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/chart-infographic.svg', color: _currentIndex == 4 ? AppTheme.primaryColor : Colors.grey, width: 26,),
          label: '',
        ),
      ],
    );
  }
}