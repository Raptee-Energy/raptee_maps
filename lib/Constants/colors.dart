import 'package:flutter/material.dart';

class Clr {
  //cont color not depend on theme
  static const Color constWhite = Colors.white;
  static const Color constWhite1 = Color(0xFFE1E1E1);
  static const Color constBlack = Colors.black;

  //Color the depends on theme of the app

  // White
  static Color white = Colors.white; // 0xFF181818
  static Color buttonIconTeal = const Color(0xFF0BE4CD); //0xFF949494
  static Color backButtonWhite = const Color(0xFF616161); // 0xFFF4F4F4 CLASH!!!
  static Color popupIconWhite = const Color(0xFFFFF9F9);

// Black
  static Color black = Colors.black; //White
  static Color blackblack = Colors.black; //White
  static Color black1 = const Color(0xFF000D07);

// Grey
  static Color mainGrey = const Color(0xFF222222); //Same in white as well

  static Color secondarybuttonGrey = const Color(0xFF333333);
  static Color secondarytextGrey = const Color(0xFFC5C5C5);
  static Color buttonGrey = const Color(0xFF3A3A3A); //0xFFF4F4F4
  static Color buttonGrey2 = const Color(0xFF3A3A3A); //0xFFF4F4F4
  static Color outlineGrey = const Color(0xFF505050); //0xFFE3E3E3
  static Color popUpGreyBG = const Color(0xFF1F1F1F);

  static Color textGrey = const Color(0xFFA6A6A6); //Same in white as well

//Disable Colors
  static Color disableBackgroundGrey = const Color(0xFF424242);
  static Color disableIconGrey = const Color(0xFF323232);
  static Color disableGrey2 = const Color(0xFFCDCDCD); // 0xFF08999F

//Teal
  static Color brandTeal = const Color(0xFF0BE4CD); // 0xFF08999F
  static Color textTeal = const Color(0xFF00BFBF); // 0xFF00BFBF

//Other Colors:
  static Color buttonBlue = const Color(0xFF76E6FF);
  static Color buttonOrange = const Color(0xFFFFB13D);
  static Color buttonGreen = const Color(0xFF3DFF73);
  static Color buttonPurple = const Color(0xFFC376FF);

  static Color shadowColor = Colors.black;
  static Color shadowColorLight = Colors.black;

//Red
  static Color disconnectRed = const Color(0xFFFF4444); //Same in white as well
  static Color redChargeIndicator = const Color(0xFFFF0000);
  static Color redChargeIndicatorBG = const Color(0xFFFFADAD);

  //Green
  static Color green1 = const Color(0xFF7FFF43);
  static Color buttonGreen1 = const Color(0xFF00B707);
  static Color buttonBlue1 = const Color(0xFF00D2DF);
  static Color buttonRed1 = const Color(0xFFE20051);
  static Color buttonYellow1 = const Color(0xFFE9D100);
  static Color regenGreen = const Color(0xFF01D455);

  static Color wifiBTBlue = const Color(0xFF00BCE5);

// These are the normal color for use
  static const Color teal = Color(0xFF0BE4CD);
  static const Color teal2 = Color(0xFF08999F);
  static const Color tealLite = Color(0xFFB7F3F5);
  static const Color tealOriginal = Colors.teal;

  static Color ecoMode = const Color(0xFF9EFF00);
  static Color rideMode = const Color(0xFF0BE4CD);
  static Color fastMode = const Color(0xFFFF0F00);
  static Color lowBattery = const Color(0xFFFFE500);

  static Color slowChargingGradient1 = const Color(0xFF58FFD2);
  static Color slowChargingGradient2 = const Color(0xFF51FBC5);
  static Color slowChargingGradient3 = const Color(0xFF01CF21);

  static Color fastChargingGradient1 = const Color(0xFFA158FF);
  static Color fastChargingGradient2 = const Color(0xFFE451FB);
  static Color fastChargingGradient3 = const Color(0xFFCF01BA);

  //Colors for Indication
  static Color indicatorGreen = const Color(0xFF10CC00);
  static Color headLightBlue = const Color(0xFF00A3FF);
  static Color indicationYellow = const Color(0xFFFFBF00);
  static Color indicationErrorRed = const Color(0xFFFF0000);

  static Color backgroundGradientBlue =
      const Color(0xFF76E6FF).withValues(alpha: 0.5);
}
