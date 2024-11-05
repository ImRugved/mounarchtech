import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/const_textTheme.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {super.key,
      required this.press,
      required this.text,
      this.width,
      this.style,
      this.color,
      this.radius,
      this.bordercolor,
      this.height});
  final VoidCallback? press;
  final String text;
  final color;
  final bordercolor;
  final width;
  final TextStyle? style;
  final double? height;
  final double? radius;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40.h,
      width: width ?? 360.w,
      child: ElevatedButton(
        onPressed: press,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? ConstColors.green,
          side: BorderSide(color: bordercolor ?? ConstColors.green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 20.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.h, vertical: 0),
        ),
        child: FittedBox(
          child: Text(
            text,
            style: style ?? getTextTheme().bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
