import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/movement_utils.dart';

class MoneyInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color activeColor;
  final bool showAbbreviated;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;

  const MoneyInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.activeColor,
    required this.showAbbreviated,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final digitsCount = controller.text.replaceAll(RegExp(r'[^0-9]'), '').length;
    final canAbbreviate = MovementUtils.canAbbreviate(digitsCount);
    final fontSize = MovementUtils.calculateFontSize(digitsCount);

    final textColor = controller.text.isEmpty
        ? Colors.grey.shade400
        : activeColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Símbolo $
              Text(
                "\$",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              // Stack: TextField + Display abreviado
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // TextField (siempre presente, editable)
                    AnimatedOpacity(
                      opacity: showAbbreviated ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        cursorColor: activeColor,
                        cursorWidth: 2.5,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                        decoration: InputDecoration(
                          hintText: "0",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isCollapsed: true,
                        ),
                        onTap: onTap,
                        onChanged: onChanged,
                      ),
                    ),
                    // Display abreviado (clickeable para editar)
                    if (canAbbreviate)
                      AnimatedOpacity(
                        opacity: showAbbreviated ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: GestureDetector(
                          onTap: onTap,
                          child: Text(
                            MovementUtils.getAbbreviatedAmount(controller.text),
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              fontFamily: 'Poppins',
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
