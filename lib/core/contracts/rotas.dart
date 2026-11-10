// Nomes das rotas do app (contrato).

/// Rotas nomeadas do DengueZero.
abstract final class Rotas {
  /// Tela inicial.
  static const String home = '/';

  /// Quiz.
  static const String quiz = '/quiz';

  /// Resultado do quiz. Recebe `ResultadoQuizArgs` como argumento.
  static const String resultadoQuiz = '/quiz/resultado';

  /// Assistente Local: guia "Como Jogar".
  static const String assistente = '/assistente';

  /// Privacidade e fontes oficiais.
  static const String privacidade = '/privacidade';
}
