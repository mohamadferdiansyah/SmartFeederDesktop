import 'package:flutter/material.dart';

class CustomInputQty extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final double? width;
  final double? height;

  const CustomInputQty({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = -1000,
    this.max = 1000,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<CustomInputQty> createState() => _CustomInputQtyState();
}

class _CustomInputQtyState extends State<CustomInputQty> {
  late TextEditingController _controller;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _controller = TextEditingController(text: _value.toString());
  }

  void _setValue(int newValue) {
    if (newValue < widget.min) newValue = widget.min;
    if (newValue > widget.max) newValue = widget.max;
    setState(() {
      _value = newValue;
      _controller.text = _value.toString();
    });
    widget.onChanged(_value);
  }

  @override
  void didUpdateWidget(covariant CustomInputQty oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _value) {
      _value = widget.value;
      _controller.text = _value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 120,
      height: widget.height ?? 48,
      child: Row(
        children: [
          // TextField di kiri
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.blueGrey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  borderSide: BorderSide(
                    color: Colors.blueGrey.shade200,
                  ),
                ),
              ),
              onChanged: (val) {
                final v = int.tryParse(val);
                if (v != null) {
                  _setValue(v);
                }
              },
              onSubmitted: (val) {
                final v = int.tryParse(val);
                if (v != null) {
                  _setValue(v);
                } else {
                  _controller.text = _value.toString();
                }
              },
            ),
          ),
          // Plus/minus button di kanan
          Container(
            width: 40,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.blue[900]!),
                bottom: BorderSide(color: Colors.blue[900]!),
                right: BorderSide(color: Colors.blue[900]!),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _setValue(_value + 1),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.blue),
                Expanded(
                  child: InkWell(
                    onTap: () => _setValue(_value - 1),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        '-',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}