class TaxEngine2023 {
  // --- CONSTANTES OFICIALES RESOLUCIÓN 000227 (AÑO 2025) ---
  static const double UVT = 49799;

  // Topes para estar obligado a declarar (1,400 UVT)
  static const double TOPE_OBLIGACION_UVT = 1400;
  static double get topeDeclararPesos => (TOPE_OBLIGACION_UVT * UVT);

  // Topes de Deducciones e Ingresos No Constitutivos
  static const double LIMITE_VIVIENDA_ANUAL_UVT = 1200; // 100 UVT mes
  static const double LIMITE_PREPAGADA_ANUAL_UVT = 192; // 16 UVT mes

  // Nueva Deducción por Dependientes (Ley 2277 - FUERA DEL LÍMITE DEL 40%)
  static const double DEDUC_DEPENDIENTE_EXTRA_UVT = 72; // Por cada uno, hasta 4

  // Topes Rentas Exentas
  static const double TOPE_25_LABORAL_UVT =
      790; // Bajó de 2880 a 790 en la reforma
  static const double TOPE_GLOBAL_40_PCT = 0.40;
  static const double TOPE_GLOBAL_ANUAL_UVT =
      1340; // El tope máximo de beneficios

  // --- 1. VERIFICACIÓN DE OBLIGACIÓN ---
  static Map<String, dynamic> checkObligation({
    required double patrimonio,
    required double ingresos,
    required double tarjetas,
    required double consumos,
    required double consignaciones,
  }) {
    List<String> razones = [];
    double tope = topeDeclararPesos;

    if (patrimonio > (4500 * UVT))
      razones.add(
          "Patrimonio supera \$${_fmt(4500 * UVT)}"); // 4500 UVT para patrimonio
    if (ingresos > tope) razones.add("Ingresos superan \$${_fmt(tope)}");
    if (tarjetas > tope) razones.add("Gastos Tarjeta superan \$${_fmt(tope)}");
    if (consumos > tope) razones.add("Compras totales superan \$${_fmt(tope)}");
    if (consignaciones > tope)
      razones.add("Consignaciones superan \$${_fmt(tope)}");

    return {
      'obligado': razones.isNotEmpty,
      'razones': razones,
      'uvt_aplicada': UVT
    };
  }

  // --- 2. CÁLCULO DE RENTA LÍQUIDA GRAVABLE ---
  static Map<String, double> calculateTax({
    required double ingresosTotales,
    required double ingresosNoConstitutivos,
    required double deducVivienda,
    required double deducSaludPrep,
    required int
        numeroDependientes, // Ahora es numérico para la nueva deducción
    required double aportesVoluntarios,
    required double costosGastos,
  }) {
    // A. Renta Líquida Ordinaria (Ingresos Netos)
    double ingresosNetos =
        (ingresosTotales - ingresosNoConstitutivos - costosGastos)
            .roundToDouble();
    if (ingresosNetos < 0) ingresosNetos = 0;

    // B. Deducción por Dependientes (NUEVA REGLA: FUERA DEL LÍMITE DEL 40%)
    // 72 UVT por cada dependiente, máximo 4.
    int numDep = numeroDependientes > 4 ? 4 : numeroDependientes;
    double deducDependientesExtra =
        (numDep * DEDUC_DEPENDIENTE_EXTRA_UVT * UVT).roundToDouble();

    // C. Deducciones (Sujetas al tope del 40%)
    double dVivienda = deducVivienda > (LIMITE_VIVIENDA_ANUAL_UVT * UVT)
        ? (LIMITE_VIVIENDA_ANUAL_UVT * UVT)
        : deducVivienda;
    double dSalud = deducSaludPrep > (LIMITE_PREPAGADA_ANUAL_UVT * UVT)
        ? (LIMITE_PREPAGADA_ANUAL_UVT * UVT)
        : deducSaludPrep;

    double subtotalDeducciones = dVivienda + dSalud + aportesVoluntarios;

    // D. Renta Exenta del 25% (Art 206-10)
    // Base = (Ingresos Netos - Deducciones Sujetas)
    double basePara25 = ingresosNetos - subtotalDeducciones;
    double rentaExenta25 = basePara25 > 0 ? (basePara25 * 0.25) : 0;

    // Tope corregido para 2025: 790 UVT
    double tope25Pesos = TOPE_25_LABORAL_UVT * UVT;
    if (rentaExenta25 > tope25Pesos) rentaExenta25 = tope25Pesos;

    // E. Aplicación Límite Global del 40% (O 1.340 UVT)
    double beneficiosSujetosAlTope = subtotalDeducciones + rentaExenta25;

    double limiteGlobal40 = ingresosNetos * TOPE_GLOBAL_40_PCT;
    double limiteGlobalUVT = TOPE_GLOBAL_ANUAL_UVT * UVT;

    // El límite es el menor entre el 40% o las 1.340 UVT
    double limiteFinalBeneficios =
        limiteGlobal40 > limiteGlobalUVT ? limiteGlobalUVT : limiteGlobal40;

    // Beneficios totales aceptados después de aplicar el tope
    double beneficiosAplicadosSujetos =
        beneficiosSujetosAlTope > limiteFinalBeneficios
            ? limiteFinalBeneficios
            : beneficiosSujetosAlTope;

    // F. Base Gravable Final
    // Se restan los beneficios sujetos al tope Y la deducción especial de dependientes
    double baseGravable =
        ingresosNetos - beneficiosAplicadosSujetos - deducDependientesExtra;
    if (baseGravable < 0) baseGravable = 0;

    // G. Cálculo del Impuesto (Tabla Progresiva UVT)
    double baseUVT = (baseGravable / UVT);
    double impuestoUVT = 0;

    // Tabla de tarifas (Art 241 E.T. - Se mantiene igual en UVT)
    if (baseUVT <= 1090) {
      impuestoUVT = 0;
    } else if (baseUVT <= 1700) {
      impuestoUVT = (baseUVT - 1090) * 0.19;
    } else if (baseUVT <= 4100) {
      impuestoUVT = (baseUVT - 1700) * 0.28 + 116;
    } else if (baseUVT <= 8670) {
      impuestoUVT = (baseUVT - 4100) * 0.33 + 788;
    } else if (baseUVT <= 18970) {
      impuestoUVT = (baseUVT - 8670) * 0.35 + 2296;
    } else if (baseUVT <= 31000) {
      impuestoUVT = (baseUVT - 18970) * 0.37 + 5901;
    } else {
      impuestoUVT = (baseUVT - 31000) * 0.39 + 10352;
    }

    // El resultado final debe ser redondeado al peso más cercano (Pág. 143)
    return {
      'ingresosNetos': ingresosNetos.roundToDouble(),
      'baseGravable': baseGravable.roundToDouble(),
      'beneficiosTope40': beneficiosAplicadosSujetos.roundToDouble(),
      'deduccionDependientesExtra': deducDependientesExtra.roundToDouble(),
      'impuesto': (impuestoUVT * UVT).roundToDouble()
    };
  }

  static String _fmt(double n) => n.toStringAsFixed(0);
}
