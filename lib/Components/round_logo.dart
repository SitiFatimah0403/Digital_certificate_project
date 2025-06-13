import 'package:flutter/material.dart';
import 'round_logo_model.dart';

class RoundLogoWidget extends StatefulWidget {
  final double size;
  final double fontSize;
  final String label;

  const RoundLogoWidget({
    super.key,
    this.size = 60.0,
    this.fontSize = 32.0,
    this.label = 'TrustCert',
  });

  @override
  State<RoundLogoWidget> createState() => _RoundLogoWidgetState();
}

class _RoundLogoWidgetState extends State<RoundLogoWidget> {
  late RoundLogoModel _model;

  @override
  void initState() {
    super.initState();
    _model = RoundLogoModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(widget.size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: widget.fontSize,
          color: Colors.white,
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
