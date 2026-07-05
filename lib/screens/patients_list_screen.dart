import 'dart:async';

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/patient_model.dart';
import '../services/api/doctor_api_service.dart';
import 'patient_profile_screen.dart';
import 'chat_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final DoctorApiService _doctorApiService = DoctorApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<PatientModel> _patients = [];
  List<PatientModel> _filteredPatients = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPatients();

    _searchController.addListener(() {
      _onSearchChanged(_searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
        _filteredPatients = result;
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

  Future<void> _onSearchChanged(String query) async {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      if (query.isEmpty) {
        setState(() {
          _filteredPatients = _patients;
        });
        return;
      }

      try {
        final result = await _doctorApiService.searchPatients(query);

        if (!mounted) return;

        setState(() {
          _filteredPatients = result;
        });
      } catch (_) {
        final localFiltered = _patients.where((patient) {
          return patient.fullName.toLowerCase().contains(query.toLowerCase());
        }).toList();

        if (!mounted) return;

        setState(() {
          _filteredPatients = localFiltered;
        });
      }
    });
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

    return "Patient";
  }

  String _patientVisits(PatientModel patient, int index) {
    final visits = index + 1;
    return "$visits visit${visits > 1 ? 's' : ''}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _PatientsListHeader(),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchField(
                controller: _searchController,
              ),
            ),

            const SizedBox(height: 10),
            const _PatientsFilterRow(),
            const SizedBox(height: 10),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPatients,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _ErrorState(
        message: _error!,
        onRetry: _loadPatients,
      );
    }

    if (_filteredPatients.isEmpty) {
      return const _EmptyState(
        message: "No patients found.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];

        return _PatientListCard(
          patient: patient,
          specialty: _patientSubtitle(patient),
          visits: _patientVisits(patient, index),
          avatarPath: "assets/images/patient_avatar.jpeg",
        );
      },
    );
  }
}

class _PatientsListHeader extends StatelessWidget {
  const _PatientsListHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          const Expanded(
            child: Text(
              "Patients",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "Search patients...",
        prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _PatientsFilterRow extends StatelessWidget {
  const _PatientsFilterRow();

  @override
  Widget build(BuildContext context) {
    final filters = ["A-Z", "⭐", "Critical", "New", "Robot"];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final isActive = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              filters[index],
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
  }
}

class _PatientListCard extends StatelessWidget {
  final PatientModel patient;
  final String specialty;
  final String visits;
  final String avatarPath;

  const _PatientListCard({
    required this.patient,
    required this.specialty,
    required this.visits,
    required this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(avatarPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientProfileScreen(),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      visits,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientProfileScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: AppColors.inputBackground,
              minimumSize: const Size(0, 0),
            ),
            icon: const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.primary,
            ),
            label: const Text(
              "Info",
              style: TextStyle(fontSize: 11, color: AppColors.primary),
            ),
          ),

          const SizedBox(width: 4),

          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatName: patient.fullName,
                    avatarPath: avatarPath,
                    subtitle: "$specialty • Patient",
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: AppColors.primary,
              minimumSize: const Size(0, 0),
            ),
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: Colors.white,
            ),
            label: const Text(
              "Chat",
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 32,
                ),
                const SizedBox(height: 10),
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
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}