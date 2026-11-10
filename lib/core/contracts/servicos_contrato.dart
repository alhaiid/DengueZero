// Contratos (interfaces) dos serviços usados pelos módulos.
//
// As telas dependem só destas interfaces. As implementações reais ficam em
// features/*/data e as falsas em core/fakes.

import 'package:dengue_zero/core/contracts/modelos.dart';

/// Lançada quando um conteúdo local (arquivo JSON) não pôde ser carregado.
class ConteudoIndisponivelException implements Exception {
  const ConteudoIndisponivelException(this.mensagem);

  final String mensagem;

  @override
  String toString() => 'ConteudoIndisponivelException: $mensagem';
}

/// Fornece as perguntas do quiz.
abstract interface class QuizService {
  /// Carrega todas as perguntas, na ordem em que devem ser jogadas.
  ///
  /// Lança [ConteudoIndisponivelException] se o conteúdo não puder ser lido.
  Future<List<Pergunta>> carregarPerguntas();
}

/// Guarda a pontuação do jogador, de forma anônima e local.
abstract interface class ProgressoService {
  /// Total de pontos acumulados em todas as partidas.
  Future<int> pontosTotais();

  /// Soma [pontos] ao total. Lança [ArgumentError] se não for maior que zero.
  Future<void> adicionarPontos(int pontos);
}

/// Assistente local: fornece dicas para as perguntas do quiz.
abstract interface class AssistenteService {
  /// Devolve uma pista para a [pergunta], sem revelar a resposta.
  Future<RespostaAssistente> dicaPara(Pergunta pergunta);
}
