import 'package:flutter/material.dart';
import 'package:jewelry_ledger/core/theme.dart';
import 'package:google_fonts/google_fonts.dart';

Future<T?> showAppSheet<T>(BuildContext context, {
  required String title,
  required Widget child,
  double heightFactor = 0.65,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: heightFactor,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 12,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: ListView(
          controller: scrollCtrl,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(ctx).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    ),
  );
}

Widget sheetTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    ),
  );
}

Widget sheetButton({
  required String label,
  required VoidCallback onPressed,
  Color? color,
  bool outline = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: outline
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: color ?? AppColors.primary,
              side: BorderSide(color: color ?? AppColors.primary),
            ),
            child: Text(label),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: color ?? AppColors.primary),
            child: Text(label),
          ),
  );
}
