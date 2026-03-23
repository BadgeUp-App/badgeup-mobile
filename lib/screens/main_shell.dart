import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'albums_screen.dart';
import 'map_screen.dart';
import 'ranking_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    final screens = <Widget>[
      HomeScreen(
        onProfileTapped: () {
          setState(() => _currentIndex = 4); 
        },
        onRankingTapped: () { 
          setState(() => _currentIndex = 3); 
        },
        onAlbumsTapped: () { 
          setState(() => _currentIndex = 1); 
        },
      ),

      const AlbumsScreen(),
      const MapScreen(),
      const RankingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryOrange),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark, color: AppTheme.primaryOrange),
            label: 'Albumes',
          ),
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, Color(0xFFEF4444)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, Color(0xFFEF4444)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.map_rounded, color: Colors.white, size: 22),
            ),
            label: 'Cámara',
          ),
          const NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard, color: AppTheme.primaryOrange),
            label: 'Ranking',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryOrange),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
