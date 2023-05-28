import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';

class SubHeader extends StatelessWidget {
  final String title;
  VoidCallback? function;
  Color? textColor;
  double? textSized;
  bool? enableNavigator;
  Widget? headWidget;

  SubHeader({
    Key? key,
    required this.title,
    this.function,
    this.textColor,
    this.enableNavigator,
    this.textSized,
    this.headWidget,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.only(left: 10),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      height: (height < 400) ? 50 : 80,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (enableNavigator != null && enableNavigator!)
              ? SizedBox(
                  child: InkWell(
                    onTap: (function == null)
                        ? () {
                            Navigator.of(context).pop();
                          }
                        : function,
                    child: Image.asset(
                      'assets/images/ic-pop.png',
                      fit: BoxFit.contain,
                      height: 30,
                      width: 30,
                    ),
                  ),
                )
              : (headWidget == null)
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                    )
                  : const SizedBox(),
          if (enableNavigator != null && enableNavigator! && headWidget != null)
            const Padding(padding: EdgeInsets.only(right: 10)),
          if (headWidget != null) headWidget!,
          const Padding(padding: EdgeInsets.only(right: 10)),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: (textSized != null) ? textSized : 20,
              fontWeight: FontWeight.w500,
              color:
                  (textColor != null) ? textColor : Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).cardColor,
            ),
            padding: const EdgeInsets.all(5),
            child: Image.asset(
              'assets/images/ic-viet-qr-small-trans.png',
              width: 20,
              height: 20,
            ),
          ),
          const Padding(padding: EdgeInsets.only(right: 10)),
        ],
      ),
    );
  }
}
