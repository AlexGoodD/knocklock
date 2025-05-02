import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/colors.dart'; // Asegúrate de que este archivo exista

class InputPassword extends StatefulWidget {
  final int length;
  const InputPassword({super.key, this.length = 6});

  @override
  State<InputPassword> createState() => InputPasswordState();
}

class InputPasswordState extends State<InputPassword> {
  final TextEditingController _hiddenController = TextEditingController();
  final FocusNode _hiddenFocusNode = FocusNode();
  List<String> _values = [];
  List<bool> _showCharacters = [];
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _values = List.filled(widget.length, '');
    _showCharacters = List.filled(widget.length, false);

    _hiddenFocusNode.addListener(() {
      setState(() {}); // Refresh UI to show focus state
    });
  }

  @override
  void dispose() {
    _hiddenController.dispose();
    _hiddenFocusNode.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.length > widget.length) return;

    setState(() {
      for (int i = 0; i < widget.length; i++) {
        _values[i] = i < value.length ? value[i] : '';
        _showCharacters[i] = false;
      }
      if (value.isNotEmpty) {
        int lastIndex = value.length - 1;
        _showCharacters[lastIndex] = true;

        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(milliseconds: 500), () {
          setState(() {
            _showCharacters[lastIndex] = false;
          });
        });
      }
    });
  }

  void _onTapBox() {
    FocusScope.of(context).requestFocus(_hiddenFocusNode);
  }

  void clear() {
    _hiddenController.clear();
    _onChanged('');
    FocusScope.of(context).requestFocus(_hiddenFocusNode);
  }

  String get password => _values.join();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapBox,
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.length, (index) {
                final isFocused = _hiddenFocusNode.hasFocus &&
                    _hiddenController.text.length == index;

                return Container(
                  width: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _values[index].isNotEmpty
                        ? AppColors.primaryColor
                        : AppColors.helperInputColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isFocused
                          ? AppColors.primaryColor
                          : AppColors.helperInputColor,
                      width: isFocused ? 2.0 : 1.5,
                    ),
                  ),
                  child: Text(
                    _showCharacters[index] ? _values[index] : (_values[index].isNotEmpty ? '*' : ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ),
          // Campo oculto
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _hiddenController,
              focusNode: _hiddenFocusNode,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              onChanged: _onChanged,
              autofocus: true,
              enableInteractiveSelection: false,
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ],
      ),
    );
  }
}