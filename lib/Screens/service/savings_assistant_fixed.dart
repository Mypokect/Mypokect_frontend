import 'package:flutter/material.dart';
import 'package:MyPocket/api/savings_api.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/Widgets/common/text_widget.dart';
import 'package:MyPocket/Widgets/common/button_custom.dart';
import 'package:MyPocket/Widgets/savings/savings_tab_switch_widget.dart';
import 'package:MyPocket/Widgets/savings/savings_info_row_widget.dart';
import 'package:MyPocket/utils/helpers.dart';

class AsistenteAhorroPage extends StatefulWidget {
  const AsistenteAhorroPage({super.key});

  @override
  State<AsistenteAhorroPage> createState() => _AsistenteAhorroPageState();
}

class _AsistenteAhorroPageState extends State<AsistenteAhorroPage> {
  final SavingsApi _api = SavingsApi();
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  bool _isMonthly = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  void _fetchAnalysis() async {
    try {
      final result = await _api.getAnalysis();
      if (mounted)
        setState(() {
          _data = result;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMonthly(bool value) {
    setState(() => _isMonthly = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const TextWidget(
            text: "Plan de Ahorro Inteligente",
            color: Colors.black,
            size: 17,
            fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _data == null
              ? const Center(
                  child: TextWidget(text: "No hay datos suficientes"))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final math = _data!['math_data'];
    final ai = _data!['ai_insight'];

    final double ahorroSugerido = _isMonthly
        ? double.parse(math['ahorro_mensual_sugerido'].toString())
        : double.parse(math['ahorro_semanal_sugerido'].toString());

    final Color themeColor = ai['color'] == 'red'
        ? Colors.red
        : ai['color'] == 'orange'
            ? Colors.orange
            : const Color(0xFF00C853);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          SavingsTabSwitchWidget(
            isMonthly: _isMonthly,
            onMonthlyTap: () => _toggleMonthly(true),
            onWeeklyTap: () => _toggleMonthly(false),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  formatCurrency(ahorroSugerido),
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: _isMonthly
                      ? "Ahorro Mensual Sugerido"
                      : "Ahorro Semanal Sugerido",
                  size: 14,
                  color: Colors.grey[600]!,
                ),
                const SizedBox(height: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: themeColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextWidget(
                          text: ai['mensaje'] ?? "...",
                          size: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (ai['alerta'] == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        TextWidget(
                          text: "¡Atención requerida!",
                          size: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SavingsInfoRowWidget(
              label: "Ingresos reales", value: math['ingresos']),
          SavingsInfoRowWidget(label: "Gastos reales", value: math['gastos']),
          const SizedBox(height: 30),
          ButtonCustom(text: "Volver", onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
