import 'package:flutter/material.dart';

class TempBlockButton extends StatelessWidget {
  const TempBlockButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.timer_outlined, size: 30),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Bloqueo Automático',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 5),
            const Text(
              'Tras 5 minutos de inactividad',
              style: TextStyle(fontSize: 11.5),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}