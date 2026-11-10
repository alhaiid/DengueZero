// Regras de pontuação do quiz.
//
// Fonte única: o jogo (QuizPage), o resultado (ResultadoPage) e o guia
// "Como Jogar" leem os valores daqui. Mudou um número neste arquivo, o guia
// passa a explicar a regra nova sozinho.

/// Faixas de desempenho mostradas na tela de resultado.
enum FaixaDesempenho { excelente, bom, treino }

/// Regras de pontuação do quiz.
abstract final class RegrasPontuacao {
  /// Pontos ganhos a cada resposta certa.
  static const int pontosPorAcerto = 10;

  /// Percentual mínimo de acertos para a faixa [FaixaDesempenho.excelente].
  static const int percentualExcelente = 80;

  /// Percentual mínimo de acertos para a faixa [FaixaDesempenho.bom].
  static const int percentualBom = 50;

  /// Pontos de uma partida com [acertos] respostas certas.
  ///
  /// Resposta errada e pedido de dica não descontam pontos.
  static int pontosDaPartida(int acertos) => acertos * pontosPorAcerto;

  /// Maior pontuação possível em uma partida com [totalPerguntas] perguntas.
  static int pontuacaoMaxima(int totalPerguntas) =>
      totalPerguntas * pontosPorAcerto;

  /// Menor quantidade de acertos que alcança [percentual] por cento de
  /// [totalPerguntas] perguntas.
  static int acertosMinimos(int percentual, int totalPerguntas) =>
      (percentual * totalPerguntas + 99) ~/ 100;

  /// Faixa de desempenho para [acertos] respostas certas em [total] perguntas.
  static FaixaDesempenho faixa({required int acertos, required int total}) {
    if (total <= 0) {
      return FaixaDesempenho.treino;
    }
    // Compara em inteiros (acertos / total >= percentual / 100) para não
    // depender de arredondamento.
    if (acertos * 100 >= percentualExcelente * total) {
      return FaixaDesempenho.excelente;
    }
    if (acertos * 100 >= percentualBom * total) {
      return FaixaDesempenho.bom;
    }
    return FaixaDesempenho.treino;
  }
}
