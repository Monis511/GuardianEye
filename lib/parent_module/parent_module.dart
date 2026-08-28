import 'package:flutter/material.dart';

class GuardianEyeApp extends StatelessWidget {
  const GuardianEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuardianEye Parent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1b6f68),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfff5f7f4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xfff5f7f4),
          foregroundColor: Color(0xff18302e),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xffe1e9e5)),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : const Color(0xff82918d),
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xff1b6f68)
                : const Color(0xffd9e1de),
          ),
        ),
      ),
      home: const ParentDashboard(),
    );
  }
}

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  bool _protectionEnabled = true;
  bool _usageLimitsEnabled = true;
  bool _installAlertsEnabled = true;
  bool _tamperProtectionEnabled = true;
  String _quietHours = 'Not configured';
  String _locationStatus = 'Optional module';
  String _deviceStatus = 'Connected  •  Monis’s Pixel';

  Future<void> _openParentDialog(String feature) async {
    final controller = TextEditingController();
    String selection = feature == 'App limits' ? '2 hours per day' : '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final isPairing = feature == 'Device pairing';
        final isLimits = feature == 'App limits';
        final isQuietHours = feature == 'Quiet hours';
        final isLocation = feature == 'Location';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(feature),
              content: SizedBox(
                width: 420,
                child: isPairing
                    ? TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Pairing code',
                          hintText: 'Enter the code shown on the device',
                          prefixIcon: Icon(Icons.qr_code_2_rounded),
                        ),
                      )
                    : isLimits
                        ? DropdownButtonFormField<String>(
                            initialValue: selection,
                            decoration: const InputDecoration(labelText: 'Daily screen-time limit'),
                            items: const [
                              DropdownMenuItem(value: '1 hour per day', child: Text('1 hour per day')),
                              DropdownMenuItem(value: '2 hours per day', child: Text('2 hours per day')),
                              DropdownMenuItem(value: '3 hours per day', child: Text('3 hours per day')),
                              DropdownMenuItem(value: 'No limit', child: Text('No limit')),
                            ],
                            onChanged: (value) => setDialogState(() => selection = value ?? selection),
                          )
                        : isQuietHours
                            ? DropdownButtonFormField<String>(
                                initialValue: selection.isEmpty ? '9:00 PM - 7:00 AM' : selection,
                                decoration: const InputDecoration(labelText: 'Quiet-hour schedule'),
                                items: const [
                                  DropdownMenuItem(value: '8:00 PM - 7:00 AM', child: Text('8:00 PM - 7:00 AM')),
                                  DropdownMenuItem(value: '9:00 PM - 7:00 AM', child: Text('9:00 PM - 7:00 AM')),
                                  DropdownMenuItem(value: '10:00 PM - 8:00 AM', child: Text('10:00 PM - 8:00 AM')),
                                ],
                                onChanged: (value) => setDialogState(() => selection = value ?? selection),
                              )
                            : isLocation
                                ? const Text('Location and geofencing are optional. Setup will be enabled when the Android location permission and child-device connection are available.')
                                : Text('Configure $feature for Monis’s connected device. Changes are stored locally on this parent dashboard.'),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    if (isPairing && controller.text.trim().isEmpty) return;
                    Navigator.pop(context, isPairing ? 'Connected  •  Monis’s Pixel' : isLocation ? 'Permission needed' : (selection.isEmpty ? 'Configured' : selection));
                  },
                  child: Text(isLocation ? 'Continue' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    if (!mounted || result == null) return;
    setState(() {
      if (feature == 'Device pairing') _deviceStatus = result;
      if (feature == 'Quiet hours') _quietHours = result;
      if (feature == 'Location') _locationStatus = result;
    });
    _showSaved(feature);
  }

  void _showSaved(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature settings updated locally.')),
    );
  }

  void _showInformation(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 420;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: compact ? 12 : 24,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xffd8eeea),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.shield_outlined, color: Color(0xff1b6f68)),
            ),
            const SizedBox(width: 12),
            const Text('GuardianEye', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showInformation('Notifications', 'No new alerts. GuardianEye will show pairing, install, tamper, and protection events here.'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 4),
              child: IconButton(
                tooltip: 'Parent profile',
                onPressed: () => _showInformation('Parent profile', 'Parent mode is active. A secure account and authorization flow will be connected to this profile in the Android implementation.'),
                icon: const CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xfff0d8b8),
                  child: Text('P', style: TextStyle(color: Color(0xff67462a))),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(wide ? 48 : 20, 14, wide ? 48 : 20, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcome(wide),
                      const SizedBox(height: 26),
                      _buildProtectionBanner(),
                      const SizedBox(height: 26),
                      _buildSectionHeading('At a glance', 'Today on Monis’s device'),
                      const SizedBox(height: 12),
                      _buildOverviewGrid(wide),
                      const SizedBox(height: 28),
                      _buildSectionHeading('Parent controls', 'Manage what is active'),
                      const SizedBox(height: 12),
                      _buildControlsGrid(wide),
                      const SizedBox(height: 28),
                      _buildSectionHeading('Safety coverage', 'What GuardianEye is ready to manage'),
                      const SizedBox(height: 12),
                      _buildSafetyCoverage(wide),
                      const SizedBox(height: 28),
                      _buildSectionHeading('Device health', 'Monis’s connected device'),
                      const SizedBox(height: 12),
                      _buildDeviceHealthCard(),
                      const SizedBox(height: 28),
                      _buildSectionHeading('Recent activity', 'Privacy-first event history'),
                      const SizedBox(height: 12),
                      _buildActivityCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcome(bool wide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning, Parent', style: TextStyle(fontSize: 14, color: Color(0xff61726e))),
              SizedBox(height: 5),
              Text('A calmer way to keep watch.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xff18302e))),
            ],
          ),
        ),
        if (wide)
          OutlinedButton.icon(
            onPressed: () => _openParentDialog('Device pairing'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add child device'),
          ),
      ],
    );
  }

  Widget _buildProtectionBanner() {
    return Card(
      color: const Color(0xff18302e),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 500;
          final message = Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xff2d625b), borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.verified_user_outlined, color: Color(0xffb8eee4), size: 26),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Protection is active', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Monis’s screen is being checked on-device. Nothing is uploaded.', style: TextStyle(color: Color(0xffb9c9c5), height: 1.35)),
                  ],
                ),
              ),
            ],
          );
          return Padding(
            padding: const EdgeInsets.all(18),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [message, Align(alignment: Alignment.centerRight, child: Switch(value: _protectionEnabled, onChanged: (value) => setState(() => _protectionEnabled = value)))],
                  )
                : Row(
                    children: [message, Switch(value: _protectionEnabled, onChanged: (value) => setState(() => _protectionEnabled = value))],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xff18302e))),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: Color(0xff71817d))),
      ],
    );
  }

  Widget _buildOverviewGrid(bool wide) {
    final cards = [
      _OverviewCard(icon: Icons.shield_outlined, color: const Color(0xff1b6f68), value: 'Protected', label: 'Visual safety'),
      _OverviewCard(icon: Icons.timer_outlined, color: const Color(0xffb06b2a), value: '1h 42m', label: 'Screen time'),
      _OverviewCard(icon: Icons.apps_outlined, color: const Color(0xff4b6e9b), value: '3 of 5', label: 'Apps within limit'),
    ];
    return GridView.count(
      crossAxisCount: wide ? 3 : 1,
      childAspectRatio: wide ? 2.15 : 3.3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  Widget _buildControlsGrid(bool wide) {
    final controls = [
      _ControlTile(icon: Icons.link_rounded, title: 'Device pairing', detail: _deviceStatus, action: 'Manage', onTap: () => _openParentDialog('Device pairing')),
      _ControlTile(icon: Icons.timer_outlined, title: 'App limits', detail: 'Daily limits are active', onTap: () => _openParentDialog('App limits'), trailing: Switch(value: _usageLimitsEnabled, onChanged: (value) => setState(() => _usageLimitsEnabled = value))),
      _ControlTile(icon: Icons.schedule_rounded, title: 'Quiet hours', detail: _quietHours, action: 'Set up', onTap: () => _openParentDialog('Quiet hours')),
      _ControlTile(icon: Icons.location_on_outlined, title: 'Location', detail: _locationStatus, action: 'Set up', onTap: () => _openParentDialog('Location')),
      _ControlTile(icon: Icons.download_for_offline_outlined, title: 'New app alerts', detail: 'Notify when apps are installed', trailing: Switch(value: _installAlertsEnabled, onChanged: (value) => setState(() => _installAlertsEnabled = value))),
      _ControlTile(icon: Icons.lock_outline_rounded, title: 'Tamper protection', detail: 'Uninstall lock is active', trailing: Switch(value: _tamperProtectionEnabled, onChanged: (value) => setState(() => _tamperProtectionEnabled = value))),
    ];
    return GridView.count(
      crossAxisCount: wide ? 2 : 1,
      childAspectRatio: wide ? 3.6 : 3.1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: controls,
    );
  }

  Widget _buildActivityCard() {
    return Card(
      child: Column(
        children: const [
          _ActivityRow(icon: Icons.check_circle_outline, title: 'Protection check completed', detail: 'Today, 10:42 AM', color: Color(0xff1b6f68)),
          Divider(height: 1, indent: 64, endIndent: 20),
          _ActivityRow(icon: Icons.hourglass_bottom_rounded, title: 'YouTube limit refreshed', detail: 'Today, 8:00 AM', color: Color(0xffb06b2a)),
          Divider(height: 1, indent: 64, endIndent: 20),
          _ActivityRow(icon: Icons.phonelink_rounded, title: 'Device connected securely', detail: 'Yesterday, 6:18 PM', color: Color(0xff4b6e9b)),
        ],
      ),
    );
  }

  Widget _buildSafetyCoverage(bool wide) {
    final items = [
      _CoverageItem(icon: Icons.visibility_off_outlined, title: 'Visual protection', detail: 'NSFW blur is active', status: 'ACTIVE', color: const Color(0xff1b6f68), onTap: () => _showInformation('Visual protection', 'The parent policy is enabled. The Android child service will use MediaProjection and an on-device model when that module is connected.')),
      _CoverageItem(icon: Icons.text_fields_rounded, title: 'Text safety', detail: 'On-device OCR model', status: 'NEXT', color: const Color(0xffb06b2a), onTap: () => _openParentDialog('Text safety')),
      _CoverageItem(icon: Icons.timer_outlined, title: 'Usage limits', detail: 'UsageStats tracking', status: 'ACTIVE', color: const Color(0xff4b6e9b), onTap: () => _openParentDialog('App limits')),
      _CoverageItem(icon: Icons.admin_panel_settings_outlined, title: 'Device lockdown', detail: 'Parent authorization', status: 'SETUP', color: const Color(0xff7b5c92), onTap: () => _showInformation('Device lockdown', 'Android Device Owner provisioning and uninstall protection will be completed during child-device setup.')),
      _CoverageItem(icon: Icons.notifications_active_outlined, title: 'Install alerts', detail: 'New app notifications', status: 'ACTIVE', color: const Color(0xffb06b2a), onTap: () => setState(() => _installAlertsEnabled = !_installAlertsEnabled)),
      _CoverageItem(icon: Icons.location_on_outlined, title: 'Location & zones', detail: 'Optional module', status: 'LATER', color: const Color(0xff71817d), onTap: () => _openParentDialog('Location')),
    ];
    return GridView.count(
      crossAxisCount: wide ? 3 : 1,
      childAspectRatio: wide ? 2.25 : 3.1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }

  Widget _buildDeviceHealthCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xffd8eeea),
                  child: Icon(Icons.phone_android_rounded, color: Color(0xff1b6f68)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monis’s Pixel', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xff18302e))),
                      SizedBox(height: 3),
                      Text('Connected and syncing locally', style: TextStyle(color: Color(0xff71817d), fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.wifi_rounded, color: Color(0xff1b6f68)),
                const SizedBox(width: 5),
                const Text('Online', style: TextStyle(color: Color(0xff1b6f68), fontWeight: FontWeight.w700)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(height: 1),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HealthMetric(label: 'Battery', value: '78%', icon: Icons.battery_5_bar_rounded),
                _HealthMetric(label: 'Last sync', value: '2 min ago', icon: Icons.sync_rounded),
                _HealthMetric(label: 'Storage', value: 'On device', icon: Icons.lock_outline_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.icon, required this.color, required this.value, required this.label});

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xff18302e))),
              Text(label, style: const TextStyle(fontSize: 13, color: Color(0xff71817d))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ControlTile extends StatelessWidget {
  const _ControlTile({required this.icon, required this.title, required this.detail, this.action, this.onTap, this.trailing});

  final IconData icon;
  final String title;
  final String detail;
  final String? action;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        leading: Icon(icon, color: const Color(0xff1b6f68)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff18302e))),
        subtitle: Text(detail, style: const TextStyle(fontSize: 12, color: Color(0xff71817d))),
        trailing: trailing ?? (action == null ? null : TextButton(onPressed: onTap, child: Text(action!))),
        onTap: action == null ? onTap : null,
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.icon, required this.title, required this.detail, required this.color});

  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff18302e))),
      subtitle: Text(detail, style: const TextStyle(fontSize: 12, color: Color(0xff71817d))),
    );
  }
}

class _CoverageItem extends StatelessWidget {
  const _CoverageItem({required this.icon, required this.title, required this.detail, required this.status, required this.color, this.onTap});

  final IconData icon;
  final String title;
  final String detail;
  final String status;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff18302e))),
                  const SizedBox(height: 3),
                  Text(detail, style: const TextStyle(fontSize: 12, color: Color(0xff71817d))),
                ],
              ),
            ),
            Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
          ],
        ),
      ),
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  const _HealthMetric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xff71817d), size: 20),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff18302e))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xff71817d))),
      ],
    );
  }
}