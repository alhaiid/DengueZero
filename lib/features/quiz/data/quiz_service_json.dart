import 'dart:convert';

import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/core/contracts/servicos_contrato.dart';
import 'package:flutter/services.dart';

/// Lê as perguntas do quiz do arquivo `assets/quiz/perguntas.json`.
class QuizServiceJson implements QuizService {
  QuizServiceJson({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  /// Caminho do arquivo de perguntas dentro do app.
  static const String caminhoAsset = 'assets/quiz/perguntas.json';

  final AssetBundle _bundle;
  List<Pergunta>? _cache;

  @override
  Future<List<Pergunta>> carregarPerguntas() async {
    final cache = _cache;
    if (cache != null) {
      return cache;
    }
    try {
      final texto = await _bundle.loadString(caminhoAsset);
      final perguntas = interpretarPerguntas(texto);
      _cache = perguntas;
      return perguntas;
    } catch (erro) {
      throw ConteudoIndisponivelException(
        'Não foi possível ler as perguntas do quiz ($erro).',
      );
    }
  }

  /// Converte o texto JSON na lista de perguntas.
  ///
  /// Lança um erro se o conteúdo estiver vazio ou fora do formato esperado.
  static List<Pergunta> interpretarPerguntas(String texto) {
    final itens = jsonDecode(texto) as List<dynamic>;
    final perguntas = <Pergunta>[
      for (final item in itens) Pergunta.fromJson(item as Map<String, dynamic>),
    ];
    if (perguntas.isEmpty) {
      throw const FormatException('Nenhuma pergunta encontrada.');
    }
    return List<Pergunta>.unmodifiable(perguntas);
  }
}
