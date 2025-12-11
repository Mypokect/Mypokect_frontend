class TaxEngine2023 {
  // --- CONSTANTES OFICIALES AG 2023 ---
  static const double UVT = 42412; // Valor UVT 2023
  
  // Topes para estar obligado a declarar
  static const double TOPE_PATRIMONIO = 190854000;
  static const double TOPE_INGRESOS = 59377000; // Aplica para Ingresos, Consumos, Tarjetas, Consignaciones

  // Topes de Deducciones (Valores anuales aprox según tu info)
  static const double TOPE_DEDUC_VIVIENDA = 16600000; // ~1.38M mes
  static const double TOPE_PREPAGADA = 7048000;       // ~166 UVT
  static const double DEDUC_DEPENDIENTES_FIJA = 1080000; // Según tu indicación (aunque norma suele ser 10% ingreso)

  // Topes Rentas Exentas
  static const double TOPE_25_LABORAL_UVT = 240; // 240 UVT (Aprox 10M)
  static const double TOPE_GLOBAL_40_PCT = 0.40; // Límite general de beneficios
  static const double TOPE_GLOBAL_UVT = 1340;    // 1340 UVT (Máximo absoluto de beneficios)

  // --- 1. VERIFICACIÓN DE OBLIGACIÓN ---
  static Map<String, dynamic> checkObligation({
    required double patrimonio,
    required double ingresos,
    required double tarjetas,
    required double consumos,
    required double consignaciones,
  }) {
    List<String> razones = [];
    
    if (patrimonio > TOPE_PATRIMONIO) razones.add("Patrimonio supera \$${_fmt(TOPE_PATRIMONIO)}");
    if (ingresos > TOPE_INGRESOS) razones.add("Ingresos superan \$${_fmt(TOPE_INGRESOS)}");
    if (tarjetas > TOPE_INGRESOS) razones.add("Gastos Tarjeta superan \$${_fmt(TOPE_INGRESOS)}");
    if (consumos > TOPE_INGRESOS) razones.add("Compras totales superan \$${_fmt(TOPE_INGRESOS)}");
    if (consignaciones > TOPE_INGRESOS) razones.add("Consignaciones superan \$${_fmt(TOPE_INGRESOS)}");

    return {
      'obligado': razones.isNotEmpty,
      'razones': razones
    };
  }

  // --- 2. CÁLCULO DE RENTA LÍQUIDA GRAVABLE ---
  static Map<String, double> calculateTax({
    required double ingresosTotales,
    required double ingresosNoConstitutivos, // Salud + Pensión Obligatoria
    required double deducVivienda,
    required double deducSaludPrep,
    required double deducDependientes, // Cantidad de dependientes (0 o 1)
    required double aportesVoluntarios,
    required double costosGastos, // Solo independientes
  }) {
    // A. Renta Líquida Ordinaria (Ingresos Netos)
    double ingresosNetos = ingresosTotales - ingresosNoConstitutivos - costosGastos;
    if (ingresosNetos < 0) ingresosNetos = 0;

    // B. Deducciones (Aplicando topes individuales)
    double dVivienda = deducVivienda > TOPE_DEDUC_VIVIENDA ? TOPE_DEDUC_VIVIENDA : deducVivienda;
    double dSalud = deducSaludPrep > TOPE_PREPAGADA ? TOPE_PREPAGADA : deducSaludPrep;
    // Asumimos que si manda > 0 es que tiene dependientes, aplicamos el monto fijo que indicaste
    double dDependientes = deducDependientes > 0 ? DEDUC_DEPENDIENTES_FIJA : 0; 
    
    double totalDeducciones = dVivienda + dSalud + dDependientes + aportesVoluntarios;

    // C. Renta Exenta del 25% (Art 206-10)
    // Base para el 25% = (IngresosNetos - Deducciones)
    double basePara25 = ingresosNetos - totalDeducciones;
    double rentaExenta25 = basePara25 > 0 ? basePara25 * 0.25 : 0;
    
    // Tope de 240 UVT para el 25%
    double tope25Pesos = TOPE_25_LABORAL_UVT * UVT;
    if (rentaExenta25 > tope25Pesos) rentaExenta25 = tope25Pesos;

    // D. Aplicación Límite Global del 40% (La regla de oro)
    double beneficiosTotales = totalDeducciones + rentaExenta25;
    
    // El límite es el 40% de los ingresos netos
    double limiteGlobal = ingresosNetos * TOPE_GLOBAL_40_PCT;
    // O máximo 1340 UVT
    double topeGlobalUVT = TOPE_GLOBAL_UVT * UVT;
    if (limiteGlobal > topeGlobalUVT) limiteGlobal = topeGlobalUVT;

    // Beneficios finales aceptados
    double beneficiosFinales = beneficiosTotales > limiteGlobal ? limiteGlobal : beneficiosTotales;

    // E. Base Gravable Final
    double baseGravable = ingresosNetos - beneficiosFinales;
    if (baseGravable < 0) baseGravable = 0;

    // F. Cálculo del Impuesto (Tabla Progresiva)
    double baseUVT = baseGravable / UVT;
    double impuestoUVT = 0;

    if (baseUVT > 0 && baseUVT <= 1090) {
      impuestoUVT = 0;
    } else if (baseUVT > 1090 && baseUVT <= 1700) {
      impuestoUVT = (baseUVT - 1090) * 0.19;
    } else if (baseUVT > 1700 && baseUVT <= 4100) {
      impuestoUVT = (baseUVT - 1700) * 0.28 + 116;
    } else if (baseUVT > 4100 && baseUVT <= 8670) {
      impuestoUVT = (baseUVT - 4100) * 0.33 + 788;
    } else if (baseUVT > 8670 && baseUVT <= 18970) {
      impuestoUVT = (baseUVT - 8670) * 0.35 + 2296;
    } else if (baseUVT > 18970 && baseUVT <= 31000) {
      impuestoUVT = (baseUVT - 18970) * 0.37 + 5901;
    } else if (baseUVT > 31000) {
      impuestoUVT = (baseUVT - 31000) * 0.39 + 10352;
    }

    double impuestoPesos = impuestoUVT * UVT;

    return {
      'ingresosNetos': ingresosNetos,
      'baseGravable': baseGravable,
      'beneficiosAplicados': beneficiosFinales,
      'baseUVT': baseUVT,
      'impuesto': impuestoPesos
    };
  }

  static String _fmt(double n) => n.toStringAsFixed(0);
}