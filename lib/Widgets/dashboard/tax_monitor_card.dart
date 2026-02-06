import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';

class TaxMonitorCard extends StatelessWidget {
  final int alertsExceeded;
  final int alertsWarning;
  final VoidCallback onTap;

  const TaxMonitorCard({
    super.key,
    required this.alertsExceeded,
    required this.alertsWarning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String estadoFiscal;
    final Color colorFiscal;
    final String subtitulo;

    if (alertsExceeded > 0) {
      estadoFiscal = "ALERTA";
      colorFiscal = AppTheme.errorColor;
      subtitulo = "$alertsExceeded topes superados";
    } else if (alertsWarning > 0) {
      estadoFiscal = "CUIDADO";
      colorFiscal = AppTheme.goalOrange;
      subtitulo = "$alertsWarning cerca del límite";
    } else {
      estadoFiscal = "SEGURO";
      colorFiscal = AppTheme.goalGreen;
      subtitulo = "Topes bajo control";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MONITOR FISCAL",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorFiscal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                estadoFiscal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo2',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
