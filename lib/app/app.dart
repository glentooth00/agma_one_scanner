
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../services/local_admin_auth.dart';
import '../services/scanner_auth_service.dart';
import '../scanner/scanner_screen.dart';
import 'theme.dart';

// ======================================================
// MAIN APPLICATION
// ======================================================

class AgmaScannerApp extends StatefulWidget {
  const AgmaScannerApp({super.key});

  @override
  State<AgmaScannerApp> createState() => _AgmaScannerAppState();
}

class _AgmaScannerAppState extends State<AgmaScannerApp> {
  bool _isCheckingSession = true;
  String? _sessionType;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      await LocalAdminAuth.initialize();

      final scannerUser = await ScannerAuthService.restoreSession();

      if (!mounted) return;

      if (scannerUser != null) {
        setState(() {
          _sessionType = 'scanner';
          _isCheckingSession = false;
        });
        return;
      }

      final adminLoggedIn = await LocalAdminAuth.isLoggedIn();

      if (!mounted) return;

      setState(() {
        _sessionType = adminLoggedIn ? 'admin' : null;
        _isCheckingSession = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _sessionType = null;
        _isCheckingSession = false;
      });
    }
  }

  void _handleLoginSuccess(String sessionType) {
    setState(() {
      _sessionType = sessionType;
    });
  }

  Future<void> _handleLogout() async {
    if (_sessionType == 'scanner') {
      await ScannerAuthService.logout();
    } else if (_sessionType == 'admin') {
      await LocalAdminAuth.logout();
    }

    if (!mounted) return;

    setState(() {
      _sessionType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGMA ONE Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isCheckingSession
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _sessionType != null
              ? AppShell(onLogout: _handleLogout)
              : LoginScreen(
                  onLoginSuccess: _handleLoginSuccess,
                ),
    );
  }
}

// ======================================================
// MAIN APPLICATION SHELL
// ======================================================

class AppShell extends StatefulWidget {
  final VoidCallback onLogout;

  const AppShell({
    super.key,
    required this.onLogout,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const ScannerPage(),
      const HistoryPage(),
      SettingsPage(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SETTINGS PAGE
// ======================================================

class SettingsPage extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsPage({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(onLogout: onLogout);
  }
}

// ======================================================
// DASHBOARD PAGE
// ======================================================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'AGMA ONE',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good day!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Welcome to the AGMA ONE Scanner.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Attendance Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _DashboardStat(
                      title: 'Present',
                      value: '0',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _DashboardStat(
                      title: 'Scanned',
                      value: '0',
                      icon: Icons.qr_code_scanner,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// DASHBOARD STAT CARD
// ======================================================

class _DashboardStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
            size: 25,
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SCANNER PAGE
// ======================================================

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScannerScreen();
  }
}

// ======================================================
// HISTORY PAGE
// ======================================================

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 60,
                color: AppTheme.primary,
              ),
              SizedBox(height: 16),
              Text(
                'No attendance history yet.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
