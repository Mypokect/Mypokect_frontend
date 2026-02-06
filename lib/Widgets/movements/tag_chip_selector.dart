import 'package:flutter/material.dart';
import '../../Theme/Theme.dart';

class TagChipSelector extends StatelessWidget {
  final List<String> categorias;
  final List<String> metas;
  final String? selectedTag;
  final Function(String) onTagSelected;
  final Function() onTagDeselected;
  final bool isGoalMode;
  final Color activeColor;

  const TagChipSelector({
    super.key,
    required this.categorias,
    required this.metas,
    this.selectedTag,
    required this.onTagSelected,
    required this.onTagDeselected,
    this.isGoalMode = false,
    required this.activeColor,
  });

  // =====================================================
  // HELPERS DE RESPONSIVIDAD
  // =====================================================

  double _screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  double _chipHeight(BuildContext context) {
    final width = _screenWidth(context);
    if (width < 360) return 36.0; // Más compacto
    if (width > 600) return 44.0; // Más grande en tablets
    return 40.0; // Estándar
  }

  double _fontSize(BuildContext context, double base) {
    final width = _screenWidth(context);
    if (width < 360) return base * 0.9;
    if (width > 600) return base * 1.1;
    return base;
  }

  double _iconSize(BuildContext context, double base) {
    final width = _screenWidth(context);
    if (width < 360) return base * 0.9;
    if (width > 600) return base * 1.1;
    return base;
  }

  double _verticalPadding(BuildContext context) {
    final width = _screenWidth(context);
    if (width < 360) return 6.0;
    return 8.0;
  }

  // Determinar si una etiqueta es meta
  bool _esEtiquetaMeta(String tag) {
    return tag.startsWith('💰') || tag.toLowerCase().contains('meta:');
  }

  // =====================================================
  // BUILD PRINCIPAL
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final Color blueGoal = const Color(0xFF42A5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección CATEGORÍAS
        if (categorias.isNotEmpty) ...[
          _buildCategorySection(context),
          const SizedBox(height: 16),
        ],

        // Sección METAS
        if (metas.isNotEmpty) _buildGoalsSection(context, blueGoal),
      ],
    );
  }

  // =====================================================
  // SECCIÓN CATEGORÍAS
  // =====================================================

  Widget _buildCategorySection(BuildContext context) {
    // Determinar si esta sección está inactiva
    final bool isSectionInactive = selectedTag != null && isGoalMode;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isSectionInactive ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header "🏷️ CATEGORÍAS"
          _buildSectionHeader(
            context: context,
            icon: Icons.label_outline_rounded,
            title: 'CATEGORÍAS',
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),

          // Scroll horizontal de chips
          SizedBox(
            height: _chipHeight(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = categorias[index];
                return _buildChip(
                  context: context,
                  label: tag,
                  isSelected: selectedTag == tag,
                  isGoal: false,
                  color: AppTheme.primaryColor,
                );
              },
            ),
          ),

          // Hint sutil cuando la sección está inactiva
          if (isSectionInactive) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: _iconSize(context, 12),
                  color: AppTheme.greyColor.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Toca para cambiar a registro normal',
                  style: TextStyle(
                    fontSize: _fontSize(context, 11),
                    fontWeight: FontWeight.w500,
                    color: AppTheme.greyColor.withOpacity(0.7),
                    fontFamily: 'Baloo2',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // SECCIÓN METAS
  // =====================================================

  Widget _buildGoalsSection(BuildContext context, Color blueGoal) {
    // Determinar si esta sección está inactiva
    final bool isSectionInactive = selectedTag != null && !isGoalMode;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isSectionInactive ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header "💰 METAS DE AHORRO"
          _buildSectionHeader(
            context: context,
            icon: Icons.savings_rounded,
            title: 'METAS DE AHORRO',
            color: blueGoal,
          ),
          const SizedBox(height: 8),

          // Scroll horizontal de chips
          SizedBox(
            height: _chipHeight(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: metas.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = metas[index];
                return _buildChip(
                  context: context,
                  label: tag,
                  isSelected: selectedTag == tag,
                  isGoal: true,
                  color: blueGoal,
                );
              },
            ),
          ),

          // Hint sutil cuando la sección está inactiva
          if (isSectionInactive) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: _iconSize(context, 12),
                  color: blueGoal.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Toca para cambiar a modo ahorro',
                  style: TextStyle(
                    fontSize: _fontSize(context, 11),
                    fontWeight: FontWeight.w500,
                    color: blueGoal.withOpacity(0.7),
                    fontFamily: 'Baloo2',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // WIDGETS AUXILIARES
  // =====================================================

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required bool isGoal,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => isSelected ? onTagDeselected() : onTagSelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: _verticalPadding(context),
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withOpacity(0.15) : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: _fontSize(context, 14),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? color : AppTheme.greyColor,
                fontFamily: 'Baloo2',
              ),
            ),

            // Botón X solo si está seleccionado
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                width: _iconSize(context, 22),
                height: _iconSize(context, 22),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: _iconSize(context, 14),
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: _iconSize(context, 16),
          color: color.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: _fontSize(context, 10),
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
            fontFamily: 'Baloo2',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
