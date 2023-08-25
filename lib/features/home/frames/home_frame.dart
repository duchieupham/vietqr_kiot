import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/platform_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/sub_header_widget.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';
import 'package:viet_qr_kiot/services/providers/menu_provider.dart';

class HomeFrame extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Widget footer;
  final Widget bottomMenu;
  final Widget leftMenu;

  const HomeFrame({
    super.key,
    required this.header,
    required this.body,
    required this.footer,
    required this.bottomMenu,
    required this.leftMenu,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.asset('assets/images/bg-qr.png').image,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 30)),
                if (PlatformUtils.instance.isLandscape())
                  SubHeader(
                    title: 'QUÉT MÃ QR ĐỂ THANH TOÁN',
                    enableNavigator: false,
                    textColor: AppColor.WHITE,
                    textSized: (height < 500) ? 20 : 35,
                    headWidget: Consumer<MenuProvider>(
                      builder: (context, provider, child) {
                        return InkWell(
                          onTap: () {
                            provider.updateMenuOpen(!provider.menuOpen);
                          },
                          child: BoxLayout(
                            width: 30,
                            height: 30,
                            borderRadius: 15,
                            bgColor: Theme.of(context).cardColor,
                            padding: const EdgeInsets.all(0),
                            child: (provider.menuOpen)
                                ? const Icon(
                                    Icons.close_rounded,
                                    color: AppColor.GREY_TEXT,
                                    size: 15,
                                  )
                                : const Icon(
                                    Icons.menu_rounded,
                                    color: AppColor.GREY_TEXT,
                                    size: 15,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                (PlatformUtils.instance.isLandscape())
                    ? Expanded(
                        child: SizedBox(
                          width: width - 20,
                          child: Row(
                            children: [
                              SizedBox(
                                width: width * 0.5 - 15,
                                child: Column(
                                  children: [
                                    BoxLayout(
                                      width: width * 0.5 - 15,
                                      height: height * 0.5 - 10,
                                      child: header,
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 10)),
                                    BoxLayout(
                                      width: width * 0.5 - 15,
                                      height: (height < 400)
                                          ? height * 0.5 - 90
                                          : height * 0.5 - 120,
                                      padding: const EdgeInsets.all(0),
                                      child: footer,
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 10)),
                              BoxLayout(
                                width: width * 0.5 - 15,
                                height: height,
                                padding: const EdgeInsets.all(0),
                                child: body,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            BoxLayout(
                              width: width,
                              height: 200,
                              child: header,
                            ),
                            const Padding(padding: EdgeInsets.only(top: 10)),
                            BoxLayout(
                              width: width,
                              height: height - 280,
                              child: body,
                            ),
                            const Padding(padding: EdgeInsets.only(top: 10)),
                            BoxLayout(
                              width: width,
                              height: 200,
                              child: footer,
                            ),
                          ],
                        ),
                      ),
                const Padding(padding: EdgeInsets.only(top: 10)),
              ],
            ),
          ),
          if (!PlatformUtils.instance.isLandscape())
            Consumer<MenuProvider>(
              builder: (context, provider, child) {
                return AnimatedPositioned(
                  right: 0,
                  bottom: (provider.menuOpen) ? 60 : 0,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: InkWell(
                    onTap: () {
                      provider.updateMenuOpen(!provider.menuOpen);
                    },
                    child: Container(
                      width: 40,
                      height: 25,
                      // borderRadius: 20,
                      // bgColor: Theme.of(context).buttonColor.withOpacity(0.5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5)),
                        color: Theme.of(context).cardColor.withOpacity(0.8),
                      ),
                      padding: const EdgeInsets.all(0),
                      child: (provider.menuOpen)
                          ? const Icon(
                              Icons.close_rounded,
                              color: AppColor.GREY_TEXT,
                              size: 15,
                            )
                          : const Icon(
                              Icons.menu_rounded,
                              color: AppColor.GREY_TEXT,
                              size: 15,
                            ),
                    ),
                  ),
                );
              },
            ),
          if (PlatformUtils.instance.isLandscape())
            Consumer<MenuProvider>(
              builder: (context, provider, child) {
                return AnimatedPositioned(
                  top: 80,
                  left: (provider.menuOpen) ? 0 : -250,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: BoxLayout(
                    width: 250,
                    height: height - 90,
                    bgColor: Theme.of(context).cardColor,
                    enableShadow: true,
                    padding: const EdgeInsets.all(0),
                    child: leftMenu,
                  ),
                );
              },
            ),
          if (!PlatformUtils.instance.isLandscape())
            Consumer<MenuProvider>(
              builder: (context, provider, child) {
                return AnimatedPositioned(
                  right: 0,
                  bottom: (provider.menuOpen) ? 0 : -60,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: Container(
                    width: width,
                    height: 60,
                    color: Theme.of(context).cardColor,
                    child: bottomMenu,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
