import 'package:flutter/material.dart';
import 'package:depd_mvvm_2025/shared/style.dart'; 
import 'package:depd_mvvm_2025/view/pages/pages.dart'; // Import to access all pages

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // !! default page opened
  int _selectedIndex = 0;

 // widget navigation structure in array
  static final List<Widget> _widgetOptions = <Widget>[
    // index 0 = home / domestic
    const HomePage(), 
    // index 1: international
    const InternationalPage(),
    // index 2: blankpage
    const BlankPage(),
  ];

  // !! on tap function to change page, selectedIndex = opened tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // !! app bar title
  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Domestic Shipping';
      case 1:
        return 'International Shipping';
      case 2:
        return 'Home Dashboard (Hello World)';
      default:
        return 'Shipping Cost App';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app bar title changes based on selected tab
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Style.blue800,
        foregroundColor: Style.white,
        centerTitle: true,
      ),
      
      //!! based on selected tab
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // !! navigation bar at the bottom
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // domestic
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Domestic',
          ),
          // international
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_takeoff), 
            label: 'International',
          ),
          // blankpage
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_rounded), 
            label: 'Hello',
          ),
        ],
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped, 
        
        selectedItemColor: Style.blue800, // opened tab
        unselectedItemColor: Colors.grey, //un-opened tab
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed, // Ensures items are always visible
      ),
    );
  }
}