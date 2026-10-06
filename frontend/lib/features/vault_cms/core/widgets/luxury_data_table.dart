import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/vault_tokens.dart';

class LuxuryTableColumn {
  final String label;
  final double? width;
  final Alignment alignment;

  const LuxuryTableColumn({
    required this.label,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

class LuxuryDataTable extends StatelessWidget {
  const LuxuryDataTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.rowBuilder,
    this.emptyMessage = 'No records found in this vault vault query.',
  });

  final List<LuxuryTableColumn> columns;
  final int rowCount;
  final List<Widget> Function(BuildContext context, int index) rowBuilder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (rowCount == 0) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x38061A14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 44, color: VaultTokens.mutedGold),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: VaultTokens.sageMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x40061A14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 800),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0x55092620)),
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return const Color(0x33C7A45B);
                }
                return Colors.transparent;
              }),
              horizontalMargin: 20,
              columnSpacing: 24,
              dividerThickness: 0.6,
              columns: columns.map((col) {
                return DataColumn(
                  label: Container(
                    width: col.width,
                    alignment: col.alignment,
                    child: Text(
                      col.label.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: VaultTokens.champagneGold,
                      ),
                    ),
                  ),
                );
              }).toList(),
              rows: List.generate(rowCount, (rowIndex) {
                final cells = rowBuilder(context, rowIndex);
                return DataRow(
                  cells: cells.map((cell) => DataCell(cell)).toList(),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
