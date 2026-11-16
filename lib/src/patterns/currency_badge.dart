import 'package:bitcr_ui/src/core/flags.dart';
import 'package:bitcr_ui/src/theme/colors.dart';
import 'package:material_ui/material_ui.dart';

class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({super.key, required this.code});

  final String code;

  static const double size = 32;

  static const _bitcoinOrange = Color(0xFFF7931A);

  @override
  Widget build(BuildContext context) {
    final colors = BitcrColors.of(context);
    final lower = code.toLowerCase();

    if (lower == 'btc' || lower == 'sat') {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: _bitcoinOrange,
          shape: BoxShape.circle,
        ),
        child: const Text(
          'B',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (currencyFlag(lower) case final flag?) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox.square(
          dimension: size,
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Text(
              flag,
              style: const TextStyle(fontSize: 28, height: 38 / 28),
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.elevation200,
        shape: BoxShape.circle,
      ),
      child: Text(
        lower.substring(0, lower.length < 3 ? lower.length : 3).toUpperCase(),
        style: TextStyle(
          color: colors.text200,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
