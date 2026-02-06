import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Theme/Theme.dart';
import '../Widgets/common/text_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSuggestTags = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSuggestTags = prefs.getBool('auto_suggest_tags') ?? true;
    });
  }

  Future<void> _saveAutoSuggest(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_suggest_tags', value);
    setState(() {
      _autoSuggestTags = value;
    });

    // Mostrar confirmación
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Sugerencias automáticas activadas'
              : 'Sugerencias automáticas desactivadas'),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextWidget(
          text: "CONFIGURACIÓN",
          size: 13,
          fontWeight: FontWeight.w800,
          color: Colors.grey,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            title: "Sugerencias Inteligentes",
            subtitle: "Configuración de IA para movimientos",
            children: [
              _buildSwitchTile(
                title: "Sugerencias Automáticas (Texto)",
                subtitle: "Sugerir etiquetas mientras escribes",
                value: _autoSuggestTags,
                icon: Icons.auto_awesome_rounded,
                onChanged: _saveAutoSuggest,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "La voz siempre usa IA automáticamente. Este ajuste solo afecta cuando escribes manualmente.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: title,
          size: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.primaryColor.withOpacity(0.15)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? AppTheme.primaryColor : Colors.grey.shade600,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.5),
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
