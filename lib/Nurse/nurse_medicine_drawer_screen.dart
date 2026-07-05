import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NurseMedicineDrawerScreen extends StatefulWidget {
  final bool initialOpen;
  const NurseMedicineDrawerScreen({super.key, this.initialOpen = false});

  @override
  State<NurseMedicineDrawerScreen> createState() => _NurseMedicineDrawerScreenState();
}

class _NurseMedicineDrawerScreenState extends State<NurseMedicineDrawerScreen> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen;
  }

  void _toggle(bool v) {
    setState(() => _open = v);
    // TODO: robotService.openDrawer/closeDrawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text("Medicine Drawer", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context, _open),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(16)),
                    child: Icon(_open ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Drawer Status",
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
                    ),
                  ),
                  Switch(
                    value: _open,
                    activeColor: AppColors.primary,
                    onChanged: _toggle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _open),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
