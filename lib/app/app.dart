
import 'package:flutter/material.dart';
import 'theme.dart';

class AgmaScannerApp extends StatelessWidget {
  const AgmaScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGMA ONE Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}

// ======================================================
// APPLICATION SHELL
// ======================================================

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(
            onStartScanning: () => _changePage(1),
          ),
          const ScannerPage(),
          const HistoryPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changePage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// DASHBOARD
// ======================================================

class DashboardPage extends StatelessWidget {
  final VoidCallback onStartScanning;

  const DashboardPage({super.key, required this.onStartScanning});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BRAND HEADER
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AGMA ONE',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'SCANNER APPLICATION',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.3,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.sageLight,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: AppTheme.sage,
                        size: 8,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'OFFLINE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),

            // GREETING
            const Text(
              'Good day, Staff',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Welcome to your AGMA ONE scanner dashboard.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 25),

            // STATION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFB7D49F),
                        size: 19,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'ASSIGNED SCANNING STATION',
                        style: TextStyle(
                          color: Color(0xFFCAD4DC),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Not Assigned',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Your assigned station will appear here after login.',
                    style: TextStyle(
                      color: Color(0xFFB9C5CE),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 13),
                  const Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFFB7D49F),
                        size: 16,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Authorized scanner access',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ATTENDANCE SUMMARY
            const Text(
              'Attendance Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 13),

            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Scanned Today',
                    value: '0',
                    icon: Icons.qr_code_scanner_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Confirmed',
                    value: '0',
                    icon: Icons.verified_outlined,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Pending',
                    value: '0',
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.warning,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Records',
                    value: '0',
                    icon: Icons.people_outline_rounded,
                    color: AppTheme.sage,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 27),

            // QUICK ACTION
            const Text(
              'Quick Action',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 13),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartScanning,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Start Scanning'),
              ),
            ),

            const SizedBox(height: 18),

            const Center(
              child: Text(
                'AGMA ONE • EVENT MANAGEMENT SYSTEM',
                style: TextStyle(
                  color: Color(0xFF9AA4AF),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// STAT CARD
// ======================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SCANNER PLACEHOLDER
// ======================================================

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.qr_code_scanner_rounded,
      title: 'QR Scanner',
      description: 'Scan a member QR code to retrieve their registration information.',
    );
  }
}

// ======================================================
// HISTORY PLACEHOLDER
// ======================================================

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.history_rounded,
      title: 'Scan History',
      description: 'Your recent member scans and attendance confirmations will appear here.',
    );
  }
}

// ======================================================
// SETTINGS PLACEHOLDER
// ======================================================

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.settings_outlined,
      title: 'Settings',
      description: 'Manage your scanner account, assigned station, and application preferences.',
    );
  }
}

// ======================================================
// REUSABLE PLACEHOLDER
// ======================================================

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppTheme.sageLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  size: 38,
                  color: AppTheme.sage,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
