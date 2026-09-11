/// The corner-radius scale.
/// A few values are deliberately still literal at their call site because
/// they are shape choices rather than scale steps: fully rounded pills and
/// avatars (`circular(50)`, `circular(80)`) and hairline bars
/// (`circular(1)`).
abstract final class BitcrRadius {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;
}
