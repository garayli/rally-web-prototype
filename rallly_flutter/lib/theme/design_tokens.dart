import 'package:flutter/material.dart';

class Spacing {
  Spacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double gutter = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class RallyRadius {
  RallyRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double input = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

class RallyElevation {
  RallyElevation._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(color: Color(0x33000000), blurRadius: 32, offset: Offset(0, 16)),
  ];

  static const List<BoxShadow> hairline = [
    BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
}

class RallyType {
  RallyType._();

  static const TextStyle displayXL = TextStyle(
    fontFamily: 'InstrumentSerif', fontSize: 48, height: 1.05, letterSpacing: -2,
  );
  static const TextStyle displayLG = TextStyle(
    fontFamily: 'InstrumentSerif', fontSize: 36, height: 1.05, letterSpacing: -1.5,
  );
  static const TextStyle displayMD = TextStyle(
    fontFamily: 'InstrumentSerif', fontSize: 28, height: 1.1, letterSpacing: -1,
  );
  static const TextStyle displaySM = TextStyle(
    fontFamily: 'InstrumentSerif', fontSize: 22, height: 1.15, letterSpacing: -0.5,
  );
  static const TextStyle figure = TextStyle(
    fontFamily: 'InstrumentSerif', fontSize: 26, height: 1, letterSpacing: -1,
  );

  static const TextStyle titleLG = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle titleMD = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle titleSM = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle bodySM = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3);
  static const TextStyle eyebrow = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, height: 1.2);
  static const TextStyle micro = TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.2);
}

class RR {
  RR._();
  static BorderRadius all(double r) => BorderRadius.circular(r);
  static BorderRadius get sm => BorderRadius.circular(RallyRadius.sm);
  static BorderRadius get md => BorderRadius.circular(RallyRadius.md);
  static BorderRadius get lg => BorderRadius.circular(RallyRadius.lg);
  static BorderRadius get xl => BorderRadius.circular(RallyRadius.xl);
  static BorderRadius get xxl => BorderRadius.circular(RallyRadius.xxl);
  static BorderRadius get pill => BorderRadius.circular(RallyRadius.pill);
  static BorderRadius get sheetTop => const BorderRadius.vertical(
    top: Radius.circular(RallyRadius.sheet),
  );
}

class Pad {
  Pad._();
  static const EdgeInsets none = EdgeInsets.zero;
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: Spacing.gutter);
  static EdgeInsets all(double v) => EdgeInsets.all(v);
  static EdgeInsets h(double v) => EdgeInsets.symmetric(horizontal: v);
  static EdgeInsets v(double v) => EdgeInsets.symmetric(vertical: v);
  static EdgeInsets hv(double h, double v) => EdgeInsets.symmetric(horizontal: h, vertical: v);
}
