import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../core/storage/secure_storage_service.dart';
import '../services/api/robot_api_service.dart';

enum PoxType { chickenpox, mpox, smallpox }
enum DxResult { positive, negative, pending }

String poxLabel(PoxType t) {
  switch (t) {
    case PoxType.chickenpox:
      return "Chickenpox (Varicella)";
    case PoxType.mpox:
      return "Mpox (Monkeypox)";
    case PoxType.smallpox:
      return "Smallpox (Variola)";
  }
}

class RobotTreatmentPlansScreen extends StatefulWidget {
  const RobotTreatmentPlansScreen({super.key});

  @override
  State<RobotTreatmentPlansScreen> createState() =>
      _RobotTreatmentPlansScreenState();
}

class _RobotTreatmentPlansScreenState extends State<RobotTreatmentPlansScreen> {
  final RobotApiService _robotApiService = RobotApiService();

  int _doctorId = 0;
  bool _sendingApprove = false;

  final List<_CasePlan> _cases = [
    _CasePlan(
      patientId: 1,
      patientName: "Sara Ibrahim",
      room: "105",
      poxType: PoxType.chickenpox,
      result: DxResult.positive,
      plan:
      "• Isolation & hydration\n• Paracetamol if fever\n• Itch relief + skin care\n• Follow-up in 48h",
      status: "Pending",
    ),
    _CasePlan(
      patientId: 2,
      patientName: "Mariam Hassan",
      room: "118",
      poxType: PoxType.mpox,
      result: DxResult.positive,
      plan:
      "• Isolation\n• Skin lesion care\n• Pain relief if needed\n• Doctor review required",
      status: "Pending",
    ),
    _CasePlan(
      patientId: 3,
      patientName: "Youssef Hassan",
      room: "210",
      poxType: PoxType.smallpox,
      result: DxResult.negative,
      plan: "No plan (negative diagnosis)",
      status: "Declined",
    ),
  ];

  bool _positiveOnly = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    final saved = await SecureStorageService.getUserId();
    setState(() {
      _doctorId = int.tryParse(saved ?? '') ?? 0;
    });
  }

  List<_CasePlan> get _filteredCases {
    final all = List<_CasePlan>.from(_cases);

    if (_positiveOnly) {
      return all.where((c) => c.result == DxResult.positive).toList();
    }
    return all;
  }

  Future<void> _approve(_CasePlan c) async {
    if (_doctorId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor ID not found. Please login first.")),
      );
      return;
    }

    try {
      setState(() => _sendingApprove = true);

      await _robotApiService.sendCommand(
        doctorId: _doctorId,
        patientId: c.patientId,
        command: "OPEN_DRAWER",
        parameters: '{"autoCloseSeconds":30}',
      );

      if (!mounted) return;

      setState(() => c.status = "Active");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Approved + drawer open command sent"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Approve failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _sendingApprove = false);
      }
    }
  }

  void _decline(_CasePlan c) {
    setState(() => c.status = "Declined");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Declined")),
    );
  }

  void _modify(_CasePlan c) {
    final ctrl = TextEditingController(text: c.plan);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 12,
            bottom: 18 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Modify Treatment Plan",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 6,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => c.plan = ctrl.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Plan updated")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _dxColor(DxResult r) {
    switch (r) {
      case DxResult.positive:
        return Colors.redAccent;
      case DxResult.negative:
        return Colors.green;
      case DxResult.pending:
        return Colors.orange;
    }
  }

  String _dxText(DxResult r) {
    switch (r) {
      case DxResult.positive:
        return "Positive";
      case DxResult.negative:
        return "Negative";
      case DxResult.pending:
        return "Pending";
    }
  }

  @override
  Widget build(BuildContext context) {
    final cases = _filteredCases;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        title: const Text(
          "Pox Cases & Treatment Plans",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_sendingApprove)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_alt_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Show Positive Only",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Switch(
                          value: _positiveOnly,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _positiveOnly = v),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              itemCount: cases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final c = cases[i];

                return Container(
                  padding: const EdgeInsets.all(14),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundImage:
                            AssetImage("assets/images/patient_avatar.jpeg"),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.patientName,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Room ${c.room} • ${poxLabel(c.poxType)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _dxColor(c.result).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    "Diagnosis: ${_dxText(c.result)}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: _dxColor(c.result),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _SmallStatus(status: c.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          c.plan,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (c.status == "Pending" &&
                                  c.result == DxResult.positive &&
                                  !_sendingApprove)
                                  ? () => _approve(c)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                "Approve",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _modify(c),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              label: const Text(
                                "Modify",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _decline(c),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE53935),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFFE53935),
                                size: 18,
                              ),
                              label: const Text(
                                "Decline",
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatus extends StatelessWidget {
  final String status;
  const _SmallStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color c = status == "Active"
        ? Colors.green
        : status == "Pending"
        ? Colors.orange
        : status == "Declined"
        ? const Color(0xFFE53935)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: c,
        ),
      ),
    );
  }
}

class _CasePlan {
  final int patientId;
  final String patientName;
  final String room;
  final PoxType poxType;
  final DxResult result;
  String plan;
  String status;

  _CasePlan({
    required this.patientId,
    required this.patientName,
    required this.room,
    required this.poxType,
    required this.result,
    required this.plan,
    required this.status,
  });
}