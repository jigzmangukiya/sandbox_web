import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandbox_demo/modules/dashboard/user/widgets/user_dashboard_screen.dart';
import 'package:sandbox_demo/modules/dashboard/user/widgets/user_table_screen.dart';
import 'package:sandbox_demo/services/global_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMainScreen extends StatefulWidget {
  static const String route = '/main-screen';

  @override
  _UserMainScreenState createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      setState(() {
        _selectedIndex = index;
      });
    }
    // No need to handle logout here
  }

  Future<void> _logout() async {
    final bool? confirmLogout = await _showLogoutConfirmationDialog();
    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all session data

      final globalData = Provider.of<GlobalData>(context, listen: false);
      globalData.logout(); // Update GlobalData to reflect logout

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<bool?> _showLogoutConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.selected,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard_outlined),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.table_chart),
                selectedIcon: Icon(Icons.table_chart_outlined),
                label: Text('Table'),
              ),
            ],
            trailing: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0), // Add margin to provide space around the button
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _selectedIndex == 0
                ? UserDashboard() // Your Dashboard screen widget
                : UserTableScreen(), // Your Table screen widget
          ),
        ],
      ),
    );
  }
}
