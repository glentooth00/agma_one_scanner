
import 'package:flutter/material.dart';

import '../../services/server_config_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '8000');

  String _scheme = 'http';

  bool _isLoading = true;
  bool _isTesting = false;
  bool _isConnected = false;
  bool _hasTestedCurrentConfig = false;

  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguration() async {
    try {
      final savedUrl = await ServerConfigService.getServerUrl();

      if (savedUrl != null && savedUrl.isNotEmpty) {
        final uri = Uri.parse(savedUrl);

        if (mounted) {
          _hostController.text = uri.host;
          _portController.text =
              uri.hasPort ? uri.port.toString() : '';
          _scheme = uri.scheme;
        }
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to load saved server configuration.');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String? _getApiUrl() {
    try {
      return ServerConfigService.buildApiUrl(
        host: _hostController.text,
        port: _portController.text,
        scheme: _scheme,
      );
    } catch (_) {
      return null;
    }
  }

  void _onConfigurationChanged(String value) {
    setState(() {
      _isConnected = false;
      _hasTestedCurrentConfig = false;
      _statusMessage = null;
    });
  }

  Future<void> _testConnection() async {
    final apiUrl = _getApiUrl();

    if (apiUrl == null) {
      _showMessage('Please enter a valid server address and port.');
      return;
    }

    setState(() {
      _isTesting = true;
      _isConnected = false;
      _hasTestedCurrentConfig = false;
      _statusMessage = 'Testing connection...';
    });

    final connected =
        await ServerConfigService.testConnection(apiUrl);

    if (!mounted) return;

    setState(() {
      _isTesting = false;
      _isConnected = connected;
      _hasTestedCurrentConfig = true;
      _statusMessage = connected
          ? 'Successfully connected to AGMA ONE API.'
          : 'Connection failed. Check the server address and network.';
    });
  }

  Future<void> _saveConfiguration() async {
    final apiUrl = _getApiUrl();

    if (apiUrl == null) {
      _showMessage('Please enter a valid server address and port.');
      return;
    }

    if (!_isConnected || !_hasTestedCurrentConfig) {
      _showMessage('Please test the server connection first.');
      return;
    }

    try {
      await ServerConfigService.saveServerUrl(apiUrl);

      if (!mounted) return;

      _showMessage('Server configuration saved successfully.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to save server configuration.');
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout Administrator'),
        content: const Text(
          'Are you sure you want to logout from this device?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      widget.onLogout();
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final apiUrl = _getApiUrl();

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page heading
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Manage your scanner device',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Server configuration section
              _SectionHeading(
                icon: Icons.dns_outlined,
                title: 'Server Configuration',
                subtitle:
                    'Connect this device to your AGMA ONE server.',
              ),

              const SizedBox(height: 18),

              // Connection status
              _ConnectionStatus(
                isConnected: _isConnected,
                isTesting: _isTesting,
                message: _statusMessage,
              ),

              const SizedBox(height: 20),

              // Protocol
              _FieldLabel('Protocol'),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _scheme,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.security_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'http',
                    child: Text('HTTP - Local Network'),
                  ),
                  DropdownMenuItem(
                    value: 'https',
                    child: Text('HTTPS - Secure Connection'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _scheme = value;
                    _isConnected = false;
                    _hasTestedCurrentConfig = false;
                    _statusMessage = null;
                  });
                },
              ),

              const SizedBox(height: 18),

              // Server IP / Hostname
              _FieldLabel('Server IP / Hostname'),
              const SizedBox(height: 8),

              TextField(
                controller: _hostController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: '192.168.4.67',
                  prefixIcon: Icon(Icons.computer_outlined),
                ),
                onChanged: _onConfigurationChanged,
              ),

              const SizedBox(height: 18),

              // Port
              _FieldLabel('Port'),
              const SizedBox(height: 8),

              TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '8000',
                  prefixIcon: Icon(Icons.lan_outlined),
                ),
                onChanged: _onConfigurationChanged,
              ),

              const SizedBox(height: 22),

              // Generated API URL
              _FieldLabel('Generated API Base URL'),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outlineVariant,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.link,
                      color: colors.onSurfaceVariant,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(
                        apiUrl ?? 'Enter a valid server address and port',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Test connection
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: Text(
                    _isTesting ? 'Testing Connection...' : 'Test Connection',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Save configuration
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isConnected &&
                          _hasTestedCurrentConfig &&
                          !_isTesting
                      ? _saveConfiguration
                      : null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Configuration'),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Changing the server will clear the previous scanner '
                'authentication token. You will need to sign in again '
                'to the new server.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              const Divider(),

              const SizedBox(height: 20),

              // Device information
              _SectionHeading(
                icon: Icons.devices_outlined,
                title: 'Device Information',
                subtitle: 'Local scanner administrator settings.',
              ),

              const SizedBox(height: 16),

              _InfoTile(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Administrator',
                subtitle: 'Local device administrator',
              ),

              _InfoTile(
                icon: Icons.cloud_outlined,
                title: 'Saved Server',
                subtitle: _isConnected
                    ? 'Connection verified'
                    : 'Not currently verified',
              ),

              const SizedBox(height: 28),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout Administrator'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'AGMA ONE SCANNER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// REUSABLE SETTINGS WIDGETS
// --------------------------------------------------

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final bool isConnected;
  final bool isTesting;
  final String? message;

  const _ConnectionStatus({
    required this.isConnected,
    required this.isTesting,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final Color statusColor = isConnected
        ? Colors.green
        : isTesting
            ? colors.primary
            : message != null
                ? colors.error
                : colors.onSurfaceVariant;

    final IconData statusIcon = isConnected
        ? Icons.check_circle_outline
        : isTesting
            ? Icons.sync
            : message != null
                ? Icons.error_outline
                : Icons.info_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message ??
                  'No connection test performed yet.',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
    );
  }
}
