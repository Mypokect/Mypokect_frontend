import 'package:MyPocket/Screens/Movements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Screens/home.dart';
import 'Screens/service/budgets_list_screen.dart';
import 'Screens/service/budget_screen.dart';
import 'Theme/Theme.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {

  int _currentIndex = 0;
  final GlobalKey<BudgetsListScreenState> _budgetsListScreenKey = GlobalKey<BudgetsListScreenState>();
    
  @override
  Widget build(BuildContext context) {
    // The list of pages for the IndexedStack
          final List<Widget> _pages = [
          const Home(),
          BudgetsListScreen(key: _budgetsListScreenKey), // Index 1: Budgets List Screen
          Container(), // Index 2: Placeholder for the central button, which pushes a new route
          Container(), // Index 3: Placeholder (was flag icon)
          Container(), // Index 4: Placeholder (was chart infographic icon)
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (value) {
          if (value == 2) { // Central "add" button
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Movements()),
            );
            return;
          }
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
          // "Budgets" tab using the wallet icon
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
                borderRadius: const BorderRadius.all(Radius.circular(50))
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            activeIcon: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(50))
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          // The old "flag" icon tab is now just a placeholder, can be changed later
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/flag.svg', color: _currentIndex == 3 ? AppTheme.primaryColor : Colors.grey, width: 26,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/chart-infographic.svg', color: _currentIndex == 4 ? AppTheme.primaryColor : Colors.grey, width: 26,),
            label: '',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
    );
  }
}