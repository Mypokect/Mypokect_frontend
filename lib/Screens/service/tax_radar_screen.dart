import 'package:flutter/material.dart';
import 'package:MyPocket/api/tax_api.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';
import 'package:MyPocket/utils/helpers.dart'; // Importamos el helper

class TaxRadarScreen extends StatefulWidget {
  const TaxRadarScreen({super.key});
  @override
  State<TaxRadarScreen> createState() => _TaxRadarScreenState();
}

class _TaxRadarScreenState extends State<TaxRadarScreen> {
  final TaxApi _api = TaxApi();
  bool _loading = true;
  List<dynamic> _alerts = [];
  String _message = "Calculando...";

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  void _fetchAlerts() async {
    try {
      final res = await _api.getTaxAlerts();
      if (mounted)
        setState(() {
          _alerts = res['data'];
          _message = res['summary_message'];
          _loading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const TextWidget(
            text: "Radar de Topes 2026",
            color: Colors.black,
            size: 20,
            fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSummaryHeader(),
                const SizedBox(height: 30),
                const Text("Monitoreo en Tiempo Real",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey)),
                const SizedBox(height: 15),
                if (_alerts.isEmpty)
                  const Center(child: Text("Sin datos"))
                else
                  ..._alerts.map((a) => _buildDetailCard(a)),
                const SizedBox(height: 30),
                ButtonCustom(
                    text: "Volver",
                    onTap: () => Navigator.pop(context),
                    color: AppTheme.primaryColor),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    Color color1 = const Color(0xFF43A047);
    Color color2 = const Color(0xFF66BB6A);
    IconData icon = Icons.security;

    if (_message.contains("Atención") || _message.contains("superado")) {
      color1 = const Color(0xFFD32F2F);
      color2 = const Color(0xFFE57373);
      icon = Icons.warning_amber_rounded;
    } else if (_message.contains("Cuidado") || _message.contains("cerca")) {
      color1 = const Color(0xFFF57C00);
      color2 = const Color(0xFFFFB74D);
      icon = Icons.priority_high_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(colors: [color1, color2]),
          boxShadow: [
            BoxShadow(
                color: color1.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ]),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 35),
        const SizedBox(height: 10),
        const Text("DIAGNÓSTICO",
            style: TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(_message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ]),
    );
  }

  Widget _buildDetailCard(Map<String, dynamic> alert) {
    double pct = double.parse(alert['percentage'].toString());
    double cur = double.parse(alert['current_amount'].toString());
    double lim = double.parse(alert['limit_amount'].toString());
    String status = alert['status'];
    Color barColor = status == 'exceeded'
        ? Colors.red
        : (status == 'warning' ? Colors.orange : const Color(0xFF00C853));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFECEFF5),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Text(alert['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Text("${pct.clamp(0, 999)}%",
              style: TextStyle(color: barColor, fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 15),
        ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(barColor))),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Acumulado",
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text(formatCurrency(cur),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: status == 'exceeded' ? Colors.red : Colors.black87))
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text("Límite",
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text(formatCurrency(lim),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blueGrey))
          ]),
        ])
      ]),
    );
  }
}
