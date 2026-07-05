import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';

// Nurse-only robot actions screens
import 'nurse_read_temperature_screen.dart';
import 'nurse_medicine_drawer_screen.dart';

class NurseRobotAssistScreen extends StatefulWidget {
  const NurseRobotAssistScreen({super.key});

  @override
  State<NurseRobotAssistScreen> createState() => _NurseRobotAssistScreenState();
}

class _NurseRobotAssistScreenState extends State<NurseRobotAssistScreen> {
  bool _online = true;
  bool _drawerOpen = false;
  String _location = "Nurse Station";
  String _targetRoom = "Room 203";
  int _battery = 78;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _toggleOnline() {
    setState(() => _online = !_online);
    _showSnack(_online ? "Robot connected" : "Robot disconnected");
  }

  Future<void> _navigateToRoom() async {
    if (!_online) return _showSnack("Robot is offline");
    _showSnack("Navigating to $_targetRoom ...");
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _location = _targetRoom);
    _showSnack("Arrived at $_targetRoom");
  }

  void _confirmDelivery() => _showSnack("Delivery confirmed ✓");
  void _markAssisted() => _showSnack("Assistance recorded ✓");

  @override
  Widget build(BuildContext context) {
    final statusColor = _online ? const Color(0xFF2E7D32) : const Color(0xFFE53935);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              Row(
                children: [
                  _IconCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Robot Assist",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  _StatusChip(
                    text: _online ? "Online" : "Offline",
                    icon: _online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    color: statusColor,
                    onTap: _toggleOnline,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ===== Preview card =====
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      Container(
                        color: AppColors.inputBackground,
                        alignment: Alignment.center,
                        child: Text(
                          "Navigation Camera Preview",
                          style: TextStyle(
                            color: AppColors.textLight.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.videocam_outlined, size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                "Live View",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ===== Status tiles =====
              const Text(
                "Robot Status",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: _InfoTile(title: "Robot", value: "RX-01", icon: Icons.smart_toy_outlined),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoTile(title: "Battery", value: "$_battery%", icon: Icons.battery_6_bar_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      title: "Connection",
                      value: _online ? "Online" : "Offline",
                      icon: _online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _InfoTile(title: "Location", value: _location, icon: Icons.location_on_outlined)),
                ],
              ),

              const SizedBox(height: 18),

              // ===== Navigation Assist =====
              const Text(
                "Navigation Assist",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined, color: AppColors.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Target Room",
                            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _targetRoom,
                          underline: const SizedBox.shrink(),
                          items: const ["Room 203", "Room 206", "Room 210"]
                              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => setState(() => _targetRoom = v ?? _targetRoom),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GradientButton(
                      text: "Navigate to Room",
                      onTap: _navigateToRoom,
                    ),
                    const SizedBox(height: 10),

                    // ✅ FIX: Wrap instead of Row to avoid overflow
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 18 * 2 - 14 * 2 - 10) / 2,
                          child: _OutlinePillButton(
                            text: "Confirm Delivery",
                            icon: Icons.local_shipping_outlined,
                            onTap: _confirmDelivery,
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 18 * 2 - 14 * 2 - 10) / 2,
                          child: _OutlinePillButton(
                            text: "Mark Assisted",
                            icon: Icons.verified_outlined,
                            onTap: _markAssisted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ===== Movement (D-Pad) =====
              const Text(
                "Movement Controls",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),

              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DpadButton(
                        icon: Icons.keyboard_arrow_up_rounded,
                        label: "Forward",
                        onTap: () => _showSnack("Move Forward (mock)"),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DpadButton(
                            icon: Icons.keyboard_arrow_left_rounded,
                            label: "Left",
                            onTap: () => _showSnack("Move Left (mock)"),
                          ),
                          const SizedBox(width: 10),
                          _DpadCenterButton(
                            icon: Icons.stop_rounded,
                            label: "Stop",
                            onTap: () => _showSnack("Stop (mock)"),
                          ),
                          const SizedBox(width: 10),
                          _DpadButton(
                            icon: Icons.keyboard_arrow_right_rounded,
                            label: "Right",
                            onTap: () => _showSnack("Move Right (mock)"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DpadButton(
                            icon: Icons.rotate_left_rounded,
                            label: "Rotate L",
                            onTap: () => _showSnack("Rotate Left (mock)"),
                          ),
                          const SizedBox(width: 10),
                          _DpadButton(
                            icon: Icons.keyboard_arrow_down_rounded,
                            label: "Backward",
                            onTap: () => _showSnack("Move Backward (mock)"),
                          ),
                          const SizedBox(width: 10),
                          _DpadButton(
                            icon: Icons.rotate_right_rounded,
                            label: "Rotate R",
                            onTap: () => _showSnack("Rotate Right (mock)"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ===== Nurse Actions (ONLY 2) =====
              const Text(
                "Nurse Actions",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ActionCard(
                    icon: Icons.thermostat_rounded,
                    title: "Read Temperature",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NurseReadTemperatureScreen()));
                    },
                  ),
                  _ActionCard(
                    icon: Icons.inventory_2_outlined,
                    title: "Medicine Drawer",
                    onTap: () async {
                      final res = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NurseMedicineDrawerScreen(initialOpen: _drawerOpen),
                        ),
                      );
                      if (res != null) setState(() => _drawerOpen = res);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== Components ==================

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBackground),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textLight)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinePillButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlinePillButton({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: AppColors.primary.withOpacity(0.35), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DpadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DpadButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 92,
        height: 66,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.inputBackground),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class _DpadCenterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DpadCenterButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 92,
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 18, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.stop_rounded, color: Colors.white, size: 26),
            SizedBox(height: 2),
            Text("Stop", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textDark),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}
