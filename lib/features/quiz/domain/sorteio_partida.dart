import 'dart:math';

import 'package:dengue_zero/core/contracts/modelos.dart';

/// Monta cada partida do quiz a partir do banco de perguntas.
abstract final class SorteioPartida {
  /// Quantas perguntas de cada tema entram em uma partida.
  static const int perguntasPorCategoria = 6;

  /// Sorteia as perguntas de uma partida.
  ///
  /// Pega [perguntasPorCategoria] perguntas de cada tema (ou todas, se o tema
  /// tiver menos), embaralha a ordem das perguntas e a ordem das alternativas
  /// de cada uma.
  static List<Pergunta> montar(List<Pergunta> banco, Random aleatorio) {
    final partida = <Pergunta>[];
    for (final categoria in Categoria.values) {
      final doTema = banco.where((p) => p.categoria == categoria).toList()
        ..shuffle(aleatorio);
      partida.addAll(doTema.take(perguntasPorCategoria));
    }
    partida.shuffle(aleatorio);
    return List<Pergunta>.unmodifiable([
      for (final pergunta in partida) pergunta.embaralhada(aleatorio),
    ]);
  }

  /// Quantas perguntas uma partida terá com este [banco].
  static int tamanhoDaPartida(List<Pergunta> banco) {
    var total = 0;
    for (final categoria in Categoria.values) {
      final doTema = banco.where((p) => p.categoria == categoria).length;
      total += min(doTema, perguntasPorCategoria);
    }
    return total;
  }
}
