import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/imports.dart';

class TempBlockButton extends StatefulWidget {
  const TempBlockButton({super.key});

  @override
  State<TempBlockButton> createState() => _TempBlockButtonState();
}

class _TempBlockButtonState extends State<TempBlockButton> {
  bool isAutoLockActive = false;

  void toggleAutoLock() {
    setState(() {
      isAutoLockActive = !isAutoLockActive;
    });

    if (isAutoLockActive) {
      LockController().activarSeguroAutomatico();
    } else {
      LockController().desactivarSeguroAutomatico();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: toggleAutoLock,
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.timer_outlined, size: 30),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Bloqueo Automático',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 5),
              Text(
                isAutoLockActive
                    ? 'Tras 5 minutos de inactividad'
                    : 'Actualmente esta inactivo',
                style: const TextStyle(fontSize: 11.5),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}