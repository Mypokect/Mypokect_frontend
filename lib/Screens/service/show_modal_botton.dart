import 'package:MyPocket/Theme/Theme.dart';
import 'package:MyPocket/Widgets/TextInput.dart';
import 'package:MyPocket/Widgets/TextWidget.dart';
import 'package:MyPocket/Widgets/animated_toggle_switch.dart';
import 'package:MyPocket/Widgets/tipo_recordatorio_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showAddOrEditGastoBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context, 
    builder: (BuildContext context) {
      return ShowModalBotton();
    }
  );
}

class ShowModalBotton extends StatelessWidget {
  const ShowModalBotton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 5,
              width: 50,
              margin: EdgeInsets.only(top: 10, bottom: 20, left: 25),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Textwidget(text: 'Registra un recordatorio', size: 25, fontWeight: FontWeight.bold, color: AppTheme.primaryColor,),
          SizedBox(height: 10,),
          Textwidget(text: 'Agrega detalles importantes para no olvidar tus gastos futuros.', size: 16, fontWeight: FontWeight.normal, color: Colors.grey, maxLines: 2,),
          SizedBox(height: 30,),
          Textinput(controller: TextEditingController(), hintText: 'Titulo del recordatorio', icon: SvgPicture.asset('assets/svg/flag.svg'),),
          SizedBox(height: 20,),
          Textinput(controller: TextEditingController(), hintText: 'monto', icon: SvgPicture.asset('assets/svg/cash.svg'),),
          SizedBox(height: 20,),
          Container(
            child: Row(
              spacing: 10,
              children: [
                AnimatedToggleSwitch(value: true, onChanged: (value) {}),
                TipoRecordatorioSelector()
              ],
            ),
          ),
          SizedBox(height: 20,)
        ],
      )
    );
  }
}