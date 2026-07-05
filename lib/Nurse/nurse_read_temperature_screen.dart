import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NurseReadTemperatureScreen extends StatefulWidget {
  const NurseReadTemperatureScreen({super.key});

  @override
  State<NurseReadTemperatureScreen> createState() => _NurseReadTemperatureScreenState();
}

class _NurseReadTemperatureScreenState extends State<NurseReadTemperatureScreen> {
  double? _temp;
  DateTime? _time;

  void _read() {
    final now = DateTime.now();
    setState(() {
      _temp = 38.2; // TODO: sensor
      _time = now;
    });
  }

  String _fmt(DateTime? t) {
    if (t == null) return "—";
    final hh = t.hour.toString().padLeft(2, "0");
    final mm = t.minute.toString().padLeft(2, "0");
    return "$hh:$mm";
  }

  @override
  Widget build(BuildContext context) {
    final tempText = _temp == null ? "—" : "${_temp!.toStringAsFixed(1)} °C";
    final fever = _temp != null && _temp! >= 38.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text("Temperature", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900)),
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
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.thermostat_rounded, color: fever ? Colors.red : AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Latest Reading", style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(
                          tempText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: fever ? Colors.red : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text("Time: ${_fmt(_time)}", style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  if (fever)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                      child: const Text("Fever", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _read,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Read Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
