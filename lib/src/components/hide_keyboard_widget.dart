import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:flutter/material.dart';

class Hidekeyboardwidget extends StatelessWidget {
  const Hidekeyboardwidget({
    super.key,
    required this.child,
    this.additionHeight = 40,
    required this.configuration,
  });
  final Widget child;
  final double additionHeight;
  final DatagridConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final bool isKeyboardVisible = (height - availableHeight) > 200;
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: isKeyboardVisible ? 40 : 0),
              child: child,
            ),
            Visibility(
              visible: isKeyboardVisible,
              child: Positioned(
                top: availableHeight - additionHeight,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Container(
                    color: configuration.keyboardHideButtonBackgroundColor,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.keyboard_hide,
                          color:
                              configuration.keyboardHideButtonForegroundColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hide keyboard',
                          style: TextStyle(
                            color:
                                configuration.keyboardHideButtonForegroundColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
