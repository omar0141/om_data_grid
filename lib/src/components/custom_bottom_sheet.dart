import 'package:om_data_grid/src/components/hide_keyboard_widget.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:flutter/material.dart';

class OmCustomBottomSheet extends StatelessWidget {
  final Widget child;
  final OmDataGridConfiguration? configuration;

  const OmCustomBottomSheet({super.key, required this.child, this.configuration});

  @override
  Widget build(BuildContext context) {
    // Get the keyboard height
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Calculate available height for the bottom sheet
    final availableHeight = MediaQuery.of(context).size.height - keyboardHeight;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      duration: const Duration(milliseconds: 200),
      child: OmHideKeyboardWidget(
        additionHeight: 88,
        configuration: configuration ?? OmDataGridConfiguration(),
        child: Container(
          constraints: BoxConstraints(maxHeight: availableHeight * 0.9),
          child: DraggableScrollableSheet(
            initialChildSize: keyboardHeight > 0 ? 0.9 : 0.6,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          configuration?.secondaryTextColor ??
                          const Color(0xFF6B6B6B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Main content
                  Expanded(child: child),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
