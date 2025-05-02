import 'package:characters/characters.dart';

String normalizarModo(String modoRaw) {
  final sinAcentos = modoRaw
      .replaceAll(RegExp(r'[áÁ]'), 'a')
      .replaceAll(RegExp(r'[éÉ]'), 'e')
      .replaceAll(RegExp(r'[íÍ]'), 'i')
      .replaceAll(RegExp(r'[óÓ]'), 'o')
      .replaceAll(RegExp(r'[úÚ]'), 'u');

  return sinAcentos[0].toUpperCase() + sinAcentos.substring(1).toLowerCase();
}