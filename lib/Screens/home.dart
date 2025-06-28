import 'package:app_mobil_finanzas/Theme/Theme.dart';
import 'package:app_mobil_finanzas/Widgets/TextWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Textwidget(
                  text: 'Hola, David!',
                  color: Colors.white,
                  size: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildBody(),
            ],
          ),
          if (screenWidth <= 600)
            Positioned(
              top: screenHeight * 0.015, // 1.5% desde arriba
              left: screenWidth * 0.50,  // 50% del ancho de pantalla
              right: 0,
              child: Image.asset(
                'assets/images/fondo-moderno-verde-ondulado-editado.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
              ),
          ),
          Positioned(
              top: 35,
              left: 20,
              child: Container(
                width: 180,
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.bar_chart_rounded,
                            color: AppTheme.primaryColor,
                            size: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Textwidget(
                        text: '20% Efectivo',
                        color: AppTheme.primaryColor,
                        size: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      surfaceTintColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: Icon(Icons.settings, color: Colors.white),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  // body
  Widget _buildBody() {
    return Expanded(
      child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Textwidget(text: 'Tu cuenta', color: AppTheme.greyColor, size: 15, fontWeight: FontWeight.w500,),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Tarjeta principal
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Textwidget(
                                      text: 'Balance',
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    Textwidget(
                                      text: 'Conoce tu saldo',
                                      color: AppTheme.greyColor,
                                      size: 15,
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios_rounded),
                              ],
                            ),
                            SizedBox(height: 10),
                            Textwidget(
                              text: 'Tu saldo actual es',
                              color: AppTheme.greyColor,
                              size: 15,
                            ),
                            Textwidget(
                              text: '\$1,500.00',
                              color: Colors.black,
                              size: 20,
                            ),
                          ],
                        ),
                      ),

                      // Botón flotante con leve desfase
                      Positioned(
                        bottom: -25, // desfasado hacia afuera
                        left:  30,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 100,
                          height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Center(
                            child: Textwidget(
                              text: 'Conoce más de tus finanzas',
                              color: Colors.white,
                              size: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Textwidget(text: 'Transacciones principales', color: AppTheme.greyColor, size: 15, fontWeight: FontWeight.w500,),
                ),
                SizedBox(
                  height: 120,
                  child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCard(),
                        _buildCard(),
                        _buildCard(),
                        SizedBox(width: 20),
                      ],
                    ),
                ),
              ],
            ),
          )),
    );
  }

  // tarjetas transaccionales
  Widget _buildCard() {
    return Container(
      width: 120,
      margin: EdgeInsets.only(left: 20, top: 10, bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: SvgPicture.asset('assets/svg/cash-register.svg', color: Colors.grey[500],),
          ),
          Textwidget(text: 'Compras' , color: AppTheme.greyColor, size: 15, fontWeight: FontWeight.w500,),
        ],
      ),
    );
  }
}
