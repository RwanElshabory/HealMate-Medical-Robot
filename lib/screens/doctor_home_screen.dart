import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/patient_model.dart';
import '../services/api/doctor_api_service.dart';
import 'chat_hub_screen.dart';

// الشاشات التانية
import 'patients_list_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

// الشاشات الخاصة بالروبوت والمراقبة
import 'robot_control_screen.dart';
import 'monitoring_dashboard_screen.dart';

// شاشات إضافية
import 'alerts_screen.dart';
import 'patient_profile_screen.dart';
import 'approvals_screen.dart';
import 'reports_dashboard_screen.dart';
import 'treatment_plans_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const PatientsListScreen(),
      const ChatHubScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: _DoctorBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final DoctorApiService _doctorApiService = DoctorApiService();

  bool _isLoading = true;
  String? _error;
  List<PatientModel> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await _doctorApiService.getMyPatients();

      if (!mounted) return;

      setState(() {
        _patients = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _patientSubtitle(PatientModel patient) {
    final history = (patient.medicalHistory ?? '').trim();
    if (history.isNotEmpty) return history;

    final gender = (patient.gender ?? '').trim();
    final age = patient.age;

    if (gender.isNotEmpty && age != null) {
      return "$gender, $age years";
    }

    if (gender.isNotEmpty) return gender;
    if (age != null) return "$age years";
    return "No medical details";
  }

  String _visitsText(int index) {
    final visits = index + 1;
    return "$visits visit${visits > 1 ? 's' : ''}";
  }

  String _riskFromPatient(PatientModel patient) {
    final history = (patient.medicalHistory ?? '').toLowerCase();

    if (history.contains('diabetes') ||
        history.contains('heart') ||
        history.contains('hypertension') ||
        history.contains('critical')) {
      return "High";
    }

    if (history.isNotEmpty) {
      return "Medium";
    }

    return "Low";
  }

  @override
  Widget build(BuildContext context) {
    final patientCount = _patients.length;
    final previewPatients = _patients.take(3).toList();

    return RefreshIndicator(
      onRefresh: _loadPatients,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopHeader(),
            const SizedBox(height: 14),

            _PriorityPanel(
              critical: 1,
              upcoming: 2,
              missed: 0,
              message: "3 patients need attention now",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                );
              },
            ),

            const SizedBox(height: 14),

            _RobotStatusCard(
              status: "Online",
              battery: 78,
              room: "Room 203",
              task: "Vitals check in progress",
              lastUpdated: "2 min ago",
              onControl: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RobotControlScreen()),
                );
              },
            ),

            const SizedBox(height: 14),

            const _SectionTitle("Today’s Schedule"),
            const SizedBox(height: 10),
            _ScheduleCard(
              items: const [
                _ScheduleItem(time: "09:00", patient: "Olivia", task: "Check vitals"),
                _ScheduleItem(time: "11:30", patient: "Sara", task: "Drug delivery"),
                _ScheduleItem(time: "14:00", patient: "Youssef", task: "Video consult"),
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MonitoringDashboardScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    title: "Patients",
                    value: _isLoading ? "..." : "$patientCount",
                    icon: Icons.people_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PatientsListScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    title: "Alerts",
                    value: "2",
                    icon: Icons.notifications_none,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlertsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const _SectionTitle("Doctor Tools"),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _SecondaryActionButton(
                    text: "Approvals",
                    icon: Icons.verified_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ApprovalsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SecondaryActionButton(
                    text: "Treatment Plans",
                    icon: Icons.assignment_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TreatmentPlansScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _PrimaryActionButton(
              text: "Reports Dashboard",
              icon: Icons.bar_chart_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportsDashboardScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            const _SectionTitle("My Patients Today"),
            const SizedBox(height: 10),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _ErrorCard(
                message: _error!,
                onRetry: _loadPatients,
              )
            else if (_patients.isEmpty)
                const _EmptyStateCard(
                  message: "No patients assigned yet.",
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < previewPatients.length; i++)
                      _PatientTodayCard(
                        name: previewPatients[i].fullName,
                        specialty: _patientSubtitle(previewPatients[i]),
                        visits: _visitsText(i),
                        risk: _riskFromPatient(previewPatients[i]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientProfileScreen(),
                            ),
                          );
                        },
                      ),
                  ],
                ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// =================== TOP HEADER ===================

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage("assets/images/doctor_avatar.jpeg"),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, Welcome Back",
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              SizedBox(height: 2),
              Text(
                "Dr.Sara Mohamed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        _CircleIcon(
          icon: Icons.notifications_none,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlertsScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
        _CircleIcon(
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}

/// =================== PRIORITY PANEL ===================

class _PriorityPanel extends StatelessWidget {
  final int critical;
  final int upcoming;
  final int missed;
  final String message;
  final VoidCallback onTap;

  const _PriorityPanel({
    required this.critical,
    required this.upcoming,
    required this.missed,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Priority",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _PriorityChip(
                    icon: Icons.warning_amber_rounded,
                    label: "Critical",
                    value: "$critical",
                    tint: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PriorityChip(
                    icon: Icons.schedule_rounded,
                    label: "Upcoming",
                    value: "$upcoming",
                    tint: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PriorityChip(
                    icon: Icons.medication_outlined,
                    label: "Missed",
                    value: "$missed",
                    tint: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  const _PriorityChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: tint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =================== ROBOT STATUS ===================

class _RobotStatusCard extends StatelessWidget {
  final String status;
  final int battery;
  final String room;
  final String task;
  final String lastUpdated;
  final VoidCallback onControl;

  const _RobotStatusCard({
    required this.status,
    required this.battery,
    required this.room,
    required this.task,
    required this.lastUpdated,
    required this.onControl,
  });

  @override
  Widget build(BuildContext context) {
    final bool online = status.toLowerCase() == "online";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Robot Status",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (online ? Colors.green : Colors.grey).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  online ? "Online" : "Offline",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: online ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RobotInfoLine(
                  icon: Icons.battery_full,
                  label: "Battery",
                  value: "$battery%",
                ),
              ),
              Expanded(
                child: _RobotInfoLine(
                  icon: Icons.location_on_outlined,
                  label: "Room",
                  value: room,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _RobotInfoLine(
            icon: Icons.task_alt_outlined,
            label: "Active Task",
            value: task,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Last updated: $lastUpdated",
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textLight.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryActionButton(
            text: "Control Robot",
            icon: Icons.smart_toy_outlined,
            onTap: onControl,
          ),
        ],
      ),
    );
  }
}

class _RobotInfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RobotInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =================== SCHEDULE ===================

class _ScheduleItem {
  final String time;
  final String patient;
  final String task;

  const _ScheduleItem({
    required this.time,
    required this.patient,
    required this.task,
  });
}

class _ScheduleCard extends StatelessWidget {
  final List<_ScheduleItem> items;
  final VoidCallback onTap;

  const _ScheduleCard({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              Row(
                children: [
                  Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        items[i].time,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${items[i].patient} — ${items[i].task}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
              if (i != items.length - 1) ...[
                const SizedBox(height: 10),
                Divider(
                  color: AppColors.inputBackground.withOpacity(0.7),
                  height: 1,
                ),
                const SizedBox(height: 10),
              ],
            ]
          ],
        ),
      ),
    );
  }
}

/// =================== MINI STATS ===================

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _MiniStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
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
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// =================== MY PATIENTS TODAY ===================

class _PatientTodayCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String visits;
  final String risk;
  final VoidCallback onTap;

  const _PatientTodayCard({
    required this.name,
    required this.specialty,
    required this.visits,
    required this.risk,
    required this.onTap,
  });

  Color _riskColor() {
    switch (risk) {
      case "High":
        return Colors.redAccent;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = _riskColor();

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage("assets/images/patient_avatar.jpeg"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: rc.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$risk risk",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: rc,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    visits,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;

  const _EmptyStateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// =================== PRO BUTTONS ===================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: AppColors.textDark,
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  Color _lighten(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final light = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(light).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final c1 = AppColors.primary;
    final c2 = _lighten(AppColors.primary);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [c1, c2],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.22),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.35),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =================== BOTTOM NAV ===================

class _DoctorBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DoctorBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomNavItem(
            icon: Icons.home_filled,
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _BottomNavItem(
            icon: Icons.people_outline,
            index: 1,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _BottomNavItem(
            icon: Icons.chat_bubble_outline,
            index: 2,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          _BottomNavItem(
            icon: Icons.person_outline,
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return InkWell(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        size: 24,
        color: isActive ? AppColors.primary : AppColors.textLight,
      ),
    );
  }
}