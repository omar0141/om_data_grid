import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatefulWidget {
  const DefaultButton({
    super.key,
    this.text,
    this.press,
    this.backcolor,
    this.forecolor,
    this.borderColor,
    this.fontsize,
    this.submit,
    this.padding,
    this.borderRadius,
    this.leadingIcon,
    this.fontWeight,
    this.onRightClick,
    this.configuration,
    this.height,
    this.width,
  });
  final String? text;
  final Function()? press;
  final Function()? onRightClick;
  final Color? backcolor;
  final Color? borderColor;
  final Color? forecolor;
  final num? fontsize;
  final bool? submit;
  final Widget? leadingIcon;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusDirectional? borderRadius;
  final FontWeight? fontWeight;
  final DatagridConfiguration? configuration;
  final double? height;
  final double? width;

  @override
  State<DefaultButton> createState() => _DefaultButtonState();
}

class _DefaultButtonState extends State<DefaultButton> {
  bool loading = false;

  @override
  void initState() {
    loading = widget.submit ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTap: widget.onRightClick,
      child: MouseRegion(
        cursor: loading ? SystemMouseCursors.none : SystemMouseCursors.click,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.borderColor ?? Colors.transparent,
              width: 0.5,
            ),
            borderRadius:
                widget.borderRadius ??
                const BorderRadius.all(Radius.circular(6)),
          ),
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius:
                widget.borderRadius ??
                const BorderRadius.all(Radius.circular(6)),
            child: CupertinoButton(
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              color:
                  widget.backcolor ??
                  widget.configuration?.primaryColor ??
                  const Color(0xFF2196F3),
              disabledColor:
                  widget.backcolor ??
                  widget.configuration?.primaryColor ??
                  const Color(0xFF2196F3),
              padding: widget.padding ?? EdgeInsets.zero,
              onPressed: loading
                  ? () {}
                  : () async {
                      loading = true;
                      if (mounted) setState(() {});
                      await widget.press?.call();
                      loading = false;
                      if (mounted) setState(() {});
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  loading == true
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CupertinoActivityIndicator(
                            color:
                                widget.forecolor ??
                                widget.configuration?.primaryForegroundColor ??
                                Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.leadingIcon != null) ...[
                              widget.leadingIcon!,
                              const SizedBox(width: 8),
                            ],
                            if (widget.text != null)
                              Text(
                                widget.text!,
                                style: TextStyle(
                                  fontSize: widget.fontsize?.toDouble() ?? 14,
                                  color:
                                      widget.forecolor ??
                                      widget
                                          .configuration
                                          ?.primaryForegroundColor ??
                                      Colors.white,
                                  fontWeight:
                                      widget.fontWeight ?? FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
