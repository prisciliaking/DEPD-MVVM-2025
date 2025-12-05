import 'package:flutter/material.dart';
import 'package:depd_mvvm_2025/shared/style.dart'; 
import 'package:depd_mvvm_2025/view/pages/pages.dart'; // Import to access all pages

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // 1. State: Tracks the currently selected tab index.
  int _selectedIndex = 0;

  // 2. Page List: Defines the content for each tab index.
  // The order here MUST match the order of the BottomNavigationBarItems below.
  static final List<Widget> _widgetOptions = <Widget>[
    // Index 0: Domestic (home_page.dart)
    const HomePage(), 
    // Index 1: International (international_page.dart)
    const InternationalPage(),
    // Index 2: Home (blank_page.dart)
    const BlankPage(),
  ];

  // 3. Page Switcher: Updates the state when a button is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 4. Dynamic Title: Updates the AppBar title based on the current page.
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
    // The Scaffold provides the overall screen structure (AppBar and BottomNavigationBar).
    return Scaffold(
      // The AppBar shows the dynamically updated title
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Style.blue800,
        foregroundColor: Style.white,
        centerTitle: true,
      ),
      
      // The body displays the content of the currently selected page
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // The Bottom Navigation Bar handles the switching between pages.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Button 1 (Index 0): Domestic (Truck icon)
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Domestic',
          ),
          // Button 2 (Index 1): International (Plane icon)
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_takeoff), 
            label: 'International',
          ),
          // Button 3 (Index 2): Home (Grid/Dashboard icon)
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_rounded), 
            label: 'Hello',
          ),
        ],
        currentIndex: _selectedIndex, // Links to the state variable
        onTap: _onItemTapped, // Links to the page switching function
        
        // Styling to match the selected blue and unselected grey look
        selectedItemColor: Style.blue800, // Blue for the active tab
        unselectedItemColor: Colors.grey, // Grey for inactive tabs
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed, // Ensures items are always visible
      ),
    );
  }
}