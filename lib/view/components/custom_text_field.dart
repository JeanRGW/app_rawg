import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String _label;
  final IconData _icon;
  final bool _obscure;
  final TextEditingController _controller;

  const CustomTextField({
    super.key,
    required String label,
    required IconData icon,
    bool obscure = false,
    required TextEditingController controller,
  }) : _obscure = obscure,
       _icon = icon,
       _label = label,
       _controller = controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(_icon, color: Colors.white70),
        labelText: _label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
