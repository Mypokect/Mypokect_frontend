import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:MyPocket/Screens/Auth/Login.dart';
import 'package:MyPocket/Screens/goals_screen.dart';
import 'package:MyPocket/Screens/home.dart';
import 'package:MyPocket/Screens/movements.dart';
import 'package:MyPocket/Screens/service/budgets_list_screen.dart';
import 'package:MyPocket/Screens/service/savings_goals_screen_new.dart';
import 'package:MyPocket/Screens/dashboard_screen.dart';
import 'package:MyPocket/Theme/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // The list of pages for the IndexedStack
    final List<Widget> _pages = [
      const Home(),
      const BudgetsListScreen(),
      Container(),
      const SavingsGoalsScreenNew(),
      const DashboardScreen(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (value) {
          if (value == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Movements()),
            );
          }
          setState(() {
            _currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/home.svg',
              color: _currentIndex == 0 ? AppTheme.primaryColor : Colors.grey,
              width: 26,
            ),
            backgroundColor: Colors.white,
            label: '',
          ),
          // "Budgets" tab using the wallet icon
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/wallet.svg',
              color: _currentIndex == 1 ? AppTheme.primaryColor : Colors.grey,
              width: 26,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            activeIcon: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: '',
          ),
          // The old "flag" icon tab is now just a placeholder, can be changed later
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/flag.svg',
              color: _currentIndex == 3 ? AppTheme.primaryColor : Colors.grey,
              width: 26,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/chart-infographic.svg',
              color: _currentIndex == 4 ? AppTheme.primaryColor : Colors.grey,
              width: 26,
            ),
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
