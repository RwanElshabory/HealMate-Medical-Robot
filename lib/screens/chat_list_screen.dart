import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/patient_model.dart';
import '../services/api/doctor_api_service.dart';
import 'chat_screen.dart';

enum ChatListType { patients, nurses }

class ChatListScreen extends StatefulWidget {
  final ChatListType type;

  const ChatListScreen({super.key, required this.type});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final DoctorApiService _doctorApiService = DoctorApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<_ChatItem> _items = [];
  List<_ChatItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();

    _searchController.addListener(() {
      _filterChats(_searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final isPatients = widget.type == ChatListType.patients;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (isPatients) {
        final patients = await _doctorApiService
            .getMyPatients()
            .timeout(const Duration(seconds: 6));

        _items = patients.map((p) {
          return _ChatItem(
            id: p.patientId,
            name: p.fullName,
            subtitle: "${p.roomNumber ?? 'No room'} • Patient",
            avatar: "assets/images/patient_avatar.jpeg",
            category: "Patient",
            color: const Color(0xFF1F7AE0),
          );
        }).toList();

        if (_items.isEmpty) {
          _items = _mockPatients();
        }
      } else {
        _items = _mockNurses();
      }
    } catch (e) {
      // fallback local بدل ما الشاشة تفضل معلقة
      _items = isPatients ? _mockPatients() : _mockNurses();
      _error = isPatients ? "Backend unavailable. Showing demo chats." : null;
    }

    _filteredItems = List<_ChatItem>.from(_items);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _filterChats(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List<_ChatItem>.from(_items);
      });
      return;
    }

    setState(() {
      _filteredItems = _items.where((item) {
        final q = query.toLowerCase();
        return item.name.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q);
      }).toList();
    });
  }

  List<_ChatItem> _mockPatients() {
    return [
      _ChatItem(
        id: 1,
        name: "Olivia Turner",
        subtitle: "Room 203 • Patient",
        avatar: "assets/images/patient_avatar.jpeg",
        category: "Patient",
        color: const Color(0xFF1F7AE0),
      ),
      _ChatItem(
        id: 2,
        name: "Sara Ibrahim",
        subtitle: "Room 105 • Patient",
        avatar: "assets/images/patient_avatar.jpeg",
        category: "Patient",
        color: const Color(0xFF1F7AE0),
      ),
      _ChatItem(
        id: 3,
        name: "Youssef Hassan",
        subtitle: "Room 210 • Patient",
        avatar: "assets/images/patient_avatar.jpeg",
        category: "Patient",
        color: const Color(0xFF1F7AE0),
      ),
    ];
  }

  List<_ChatItem> _mockNurses() {
    return [
      _ChatItem(
        id: 101,
        name: "Nurse Mariam",
        subtitle: "ICU • Nurse",
        avatar: "assets/images/nurse.png",
        category: "Nurse",
        color: const Color(0xFF08A88A),
      ),
      _ChatItem(
        id: 102,
        name: "Nurse Ahmed",
        subtitle: "ER • Nurse",
        avatar: "assets/images/nurse.png",
        category: "Nurse",
        color: const Color(0xFF08A88A),
      ),
      _ChatItem(
        id: 103,
        name: "Nurse Salma",
        subtitle: "Ward B • Nurse",
        avatar: "assets/images/nurse.png",
        category: "Nurse",
        color: const Color(0xFF08A88A),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isPatients = widget.type == ChatListType.patients;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEAF4FF),
              Colors.white,
              isPatients ? const Color(0xFFF4F8FF) : const Color(0xFFF2FCF8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                _FancyHeader(
                  title: isPatients ? "Patients Chats" : "Nurses Chats",
                  subtitle: isPatients
                      ? "Open patient conversations and follow ongoing cases."
                      : "Stay connected with the nursing team.",
                ),
                const SizedBox(height: 18),
                _SearchBox(controller: _searchController),
                const SizedBox(height: 14),
                if (_error != null) ...[
                  _InfoBanner(message: _error!),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadItems,
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_filteredItems.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              "No chats found.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final c = _filteredItems[index];
        return _LuxuryChatCard(
          item: c,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: "chat_${c.id}",
                  chatName: c.name,
                  avatarPath: c.avatar,
                  subtitle: c.subtitle,
                  otherUserId: c.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FancyHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FancyHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Search chats...",
          hintStyle: TextStyle(
            color: AppColors.textLight.withOpacity(0.8),
            fontSize: 13,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;

  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE3A3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatItem {
  final int id;
  final String name;
  final String subtitle;
  final String avatar;
  final String category;
  final Color color;

  _ChatItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.category,
    required this.color,
  });
}

class _LuxuryChatCard extends StatelessWidget {
  final _ChatItem item;
  final VoidCallback onTap;

  const _LuxuryChatCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: item.color.withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(item.avatar),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: item.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: item.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}