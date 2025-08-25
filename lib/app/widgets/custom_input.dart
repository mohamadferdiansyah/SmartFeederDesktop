import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final double fontSize;
  final TextEditingController controller;
  final bool isPassword;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInput({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.hint,
    this.icon,
    this.fontSize = 16,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: widget.fontSize,
            ),
          ),

          const SizedBox(height: 8),
        ],
        TextField(
          controller: widget.controller,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.isPassword ? _obscure : false,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
            // Tambahkan padding di suffixIcon:
            suffixIcon: widget.isPassword
                ? Padding(
                    padding: const EdgeInsets.only(
                      right: 10.0,
                    ), // tambahkan jarak kanan
                    child: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
