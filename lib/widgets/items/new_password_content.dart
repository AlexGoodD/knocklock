import 'package:flutter/material.dart';
import '../inputs/input_password.dart';

class CreatePasswordContent extends StatelessWidget {
  final String title;
  final String description;

  const CreatePasswordContent({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        const InputPassword(length: 5), // <- Llama a un solo InputPassword
      ],
    );
  }
}

class VerifyPasswordContent extends StatelessWidget {
  final String title;
  final String description;

  const VerifyPasswordContent({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        InputPassword(
          length: 6,
        )
      ],
    );
  }
}