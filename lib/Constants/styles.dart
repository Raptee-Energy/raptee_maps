import 'package:flutter/material.dart';

import 'appFont.dart';
import 'colors.dart';

class Style {

  static TextStyle conigenWhiteRegularText({
    double fontSize = 16,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    FontStyle fontStyle = FontStyle.normal,
    double height = 1,
  }) {
    color = Clr.white;
    return TextStyle(
      height: height,
      color: color,
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: AppFont.conigen,
    );
  }

  static TextStyle conigenBlackRegularText({
    double fontSize = 16,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.w700,
    FontStyle fontStyle = FontStyle.normal,
    double height = 1,
  }) {
    color = Clr.constBlack;
    return TextStyle(
      height: height,
      color: color,
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: AppFont.conigen,
    );
  }


  static TextStyle conigenBlackRegularTextSideBar({
    double fontSize = 16,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.w700,
    FontStyle fontStyle = FontStyle.normal,
    double height = 1,
  }) {
    color = Clr.blackblack;
    return TextStyle(
      height: height,
      color: color,
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: AppFont.conigen,
    );
  }

  static TextStyle tealHeadingText({
    double fontSize = 20,
    Color color = Colors.teal,
    FontWeight fontWeight = FontWeight.bold,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    color = Clr.textTeal;
    return TextStyle(
      color: color,
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: AppFont.conigen,
    );
  }

  static TextStyle greySubHeadingText({
    double fontSize = 15,
    Color color = Colors.grey,
    FontWeight fontWeight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    color = Clr.textGrey;
    return TextStyle(
      color: color,
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: AppFont.conigen,
    );
  }

  static TextStyle greyText({
    double fontSize = 15,
    Color color = Colors.grey,
    FontWeight fontWeight = FontWeight.w500,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    color = Clr.textGrey;
    return TextStyle(
      color: color,
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: AppFont.conigen,
    );
  }

  static TextStyle conigenColorChangableRegularText({
    double fontSize = 16,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    FontStyle fontStyle = FontStyle.normal,
    double height = 1,
    double letterSpacing = 0.5,
  }) {
    color ??= Clr.white;
    return TextStyle(
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      overflow: TextOverflow.ellipsis,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: AppFont.conigen,
    );
  }

}
