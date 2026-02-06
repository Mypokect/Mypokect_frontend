import 'package:flutter/material.dart';
import 'package:MyPocket/Theme/theme.dart';
import 'package:MyPocket/utils/helpers.dart';
import 'package:MyPocket/utils/dashboard_utils.dart';
import 'package:MyPocket/Widgets/dashboard/invoice_alert_card.dart';

class InvoiceAlertsSection extends StatelessWidget {
  final double ingresosFE;
  final double gastoConFE;
  final double dineroPerdido;

  const InvoiceAlertsSection({
    super.key,
    required this.ingresosFE,
    required this.gastoConFE,
    required this.dineroPerdido,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculos de alertas
    final porcentajeDeclaracion = (ingresosFE / DashboardUtils.topeDeclaracion * 100).clamp(0.0, 100.0);
    final faltaParaDeclarar = (DashboardUtils.topeDeclaracion - ingresosFE).clamp(0.0, DashboardUtils.topeDeclaracion);
    final ahorroFE = gastoConFE * 0.01;

    // Determinar alerta de ingresos
    Color colorAlertaIngreso;
    String textoAlertaIngreso;
    IconData iconoAlertaIngreso;

    if (ingresosFE >= DashboardUtils.topeDeclaracion) {
      colorAlertaIngreso = AppTheme.errorColor;
      textoAlertaIngreso = "Debes declarar renta el próximo año";
      iconoAlertaIngreso = Icons.warning_rounded;
    } else if (porcentajeDeclaracion >= 80) {
      colorAlertaIngreso = AppTheme.goalOrange;
      textoAlertaIngreso = "Cerca del tope (${porcentajeDeclaracion.toStringAsFixed(0)}%)";
      iconoAlertaIngreso = Icons.info_outline;
    } else {
      colorAlertaIngreso = AppTheme.goalGreen;
      textoAlertaIngreso = "Aún no estás obligado a declarar";
      iconoAlertaIngreso = Icons.check_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 15),
          child: Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                "FACTURA ELECTRÓNICA",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  fontFamily: 'Baloo2',
                ),
              ),
            ],
          ),
        ),

        // 1. ALERTA DE INGRESOS
        InvoiceAlertCard(
          title: "Ingresos Facturados",
          subtitle: textoAlertaIngreso,
          mainValue: formatCurrency(ingresosFE),
          secondaryInfo: "Faltan ${formatCurrency(faltaParaDeclarar)} para declarar",
          progress: porcentajeDeclaracion / 100,
          color: colorAlertaIngreso,
          icon: iconoAlertaIngreso,
        ),

        const SizedBox(height: 12),

        // 2. CONTADOR DE AHORRO (1%)
        InvoiceAlertCard(
          title: "Tu Ahorro Fiscal",
          subtitle: "Descuento del 1% en gastos con FE",
          mainValue: formatCurrency(ahorroFE),
          secondaryInfo: "De ${formatCurrency(gastoConFE)} en compras",
          progress: null,
          color: AppTheme.primaryColor,
          icon: Icons.savings_outlined,
          isPositive: true,
        ),

        const SizedBox(height: 12),

        // 3. ALERTA DE DINERO PERDIDO
        if (dineroPerdido > 0)
          InvoiceAlertCard(
            title: "Oportunidad Perdida",
            subtitle: "Gastos sin Factura Electrónica",
            mainValue: formatCurrency(dineroPerdido),
            secondaryInfo: "No podrás deducir estos gastos",
            progress: null,
            color: Colors.orange,
            icon: Icons.error_outline,
            isNegative: true,
          ),
      ],
    );
  }
}
