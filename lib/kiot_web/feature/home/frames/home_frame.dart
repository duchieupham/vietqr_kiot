import 'package:flutter/material.dart';

import '../../../../layouts/box_layout.dart';

class HomeWebFrame extends StatelessWidget {
  final Widget layout1;
  final Widget footer;
  final Widget layout2;
  final Widget layout3;

  const HomeWebFrame({
    super.key,
    required this.layout1,
    required this.footer,
    required this.layout2,
    required this.layout3,
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
          image: Image.asset('assets/images/bgr-header.png').image,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 700) {
                    return Row(
                      children: [
                        Expanded(
                            child: Column(
                          children: [
                            Expanded(
                              child: BoxLayout(child: layout1),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: BoxLayout(
                                  padding: const EdgeInsets.all(2),
                                  child: layout3),
                            ),
                          ],
                        )),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: BoxLayout(
                                    padding: const EdgeInsets.all(2),
                                    child: layout2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: BoxLayout(child: layout1),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        flex: 2,
                        child: BoxLayout(
                            padding: const EdgeInsets.all(2), child: layout2),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: BoxLayout(
                            padding: const EdgeInsets.all(2), child: layout3),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: width,
            color: Theme.of(context).cardColor,
            child: footer,
          ),
        ],
      ),
    );
  }
}
