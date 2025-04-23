import '../core/imports.dart';

class PatronWidget extends StatefulWidget {
  final List<int> patron;
  final VoidCallback onCancel;
  final ValueNotifier<int> tiempoRestante;

  const PatronWidget({
    required this.patron,
    required this.onCancel,
    required this.tiempoRestante,
    super.key,
  });

  @override
  State<PatronWidget> createState() => _PatronWidgetState();
}

class _PatronWidgetState extends State<PatronWidget> {
  bool estaReproduciendo = false;
  bool estaPausado = false;
  int barraActiva = -1;
  Completer<void>? _pausaCompleter;

  void reproducirPatron() async {
    if (widget.patron.isEmpty || estaReproduciendo) return;

    setState(() {
      estaReproduciendo = true;
      barraActiva = 0;
      estaPausado = false;
    });

    await HapticFeedback.heavyImpact();

    for (int i = 0; i < widget.patron.length; i++) {
      await Future.delayed(Duration(milliseconds: widget.patron[i]));

      if (estaPausado) {
        _pausaCompleter = Completer<void>();
        await _pausaCompleter!.future;
      }

      await HapticFeedback.mediumImpact();

      setState(() {
        barraActiva = i + 1;
      });
    }

    await Future.delayed(Duration(milliseconds: 300));

    setState(() {
      barraActiva = -1;
      estaReproduciendo = false;
      estaPausado = false;
    });

    _pausaCompleter = null;
  }

  void pausarOContinuarReproduccion() {
    if (estaPausado) {
      continuarReproduccion();
    } else if (estaReproduciendo) {
      pausarReproduccion();
    } else {
      reproducirPatron();
    }
  }

  void pausarReproduccion() {
    if (!estaPausado && estaReproduciendo) {
      setState(() => estaPausado = true);
    }
  }

  void continuarReproduccion() {
    if (estaPausado && _pausaCompleter != null) {
      setState(() {
        estaPausado = false;
        _pausaCompleter?.complete();
      });
    }
  }

  void cancelar() {
    setState(() {
      estaReproduciendo = false;
      estaPausado = false;
      barraActiva = -1;
    });

    if (_pausaCompleter != null && !_pausaCompleter!.isCompleted) {
      _pausaCompleter!.complete();
    }
    _pausaCompleter = null;
    widget.onCancel();
  }

  String formatearSegundos(int segundos) {
    final minutos = (segundos / 60).floor();
    final seg = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: widget.tiempoRestante,
          builder: (context, value, _) {
            return Text(
              "⏰ Expira en: ${formatearSegundos(value)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            );
          },
        ),
        SizedBox(height: 20),
    if (widget.patron.isNotEmpty)

    Padding(

    padding: const EdgeInsets.symmetric(vertical: 20.0),
    child: LayoutBuilder(
    builder: (context, constraints) {
    // Ancho total disponible para las barras
    final double totalWidth = constraints.maxWidth;
    final int cantidadBarras = widget.patron.length;
    final double espacioEntreBarras = 10.0;
    final double espacioTotal = (cantidadBarras - 1) * espacioEntreBarras;
    final double anchoDisponible = totalWidth - espacioTotal;

    // Suma total de todas las duraciones
    final int duracionTotal = widget.patron.fold(0, (a, b) => a + b);

    return Row(
      children: widget.patron.asMap().entries.map((entry) {
        final index = entry.key;
        final duracion = entry.value;
        final bool activa = index == barraActiva;

        // Peso proporcional
        final int duracionTotal = widget.patron.fold(0, (a, b) => a + b);
        final double flex = duracionTotal == 0 ? 1 : duracion / duracionTotal;

        return Expanded(
          flex: (flex * 1000).round(), // más precisión para distribuciones pequeñas
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: activa ? 30 : 20,
              decoration: BoxDecoration(
                color: activa ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      }).toList(),
    );
    },
    ),
    ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: pausarOContinuarReproduccion,
              icon: Icon(estaReproduciendo && !estaPausado ? Icons.pause : Icons.play_arrow),
              label: Text(estaReproduciendo && !estaPausado ? "Pausar" : "Reproducir"),
            ),
            ElevatedButton.icon(
              onPressed: cancelar,
              icon: Icon(Icons.cancel),
              label: Text("Cancelar"),
            ),
          ],
        )
      ],
    );
  }
}