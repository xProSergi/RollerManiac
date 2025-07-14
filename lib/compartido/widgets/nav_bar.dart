import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: const Color(0xFF1E293B),
      selectedItemColor: const Color(0xFF3B82F6),
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.park_rounded, size: 28),
          label: 'Parques',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_edu_rounded, size: 26),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_rounded, size: 26),
          label: 'Social',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded, size: 26),
          label: 'Perfil',
        ),
      ],
    );
  }
}
