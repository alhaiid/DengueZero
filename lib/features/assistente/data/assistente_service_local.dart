import 'dart:convert';

import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/core/contracts/servicos_contrato.dart';
import 'package:flutter/services.dart';

/// Assistente local: busca as dicas em `assets/assistente/dicas.json`.
///
/// Funciona sem internet. Nada do que acontece no app é enviado para fora
/// do celular.
class AssistenteServiceLocal implements AssistenteService {
  AssistenteServiceLocal({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  /// Caminho do banco de dicas dentro do app.
  static const String caminhoAsset = 'assets/assistente/dicas.json';

  /// Dica usada quando o banco local não pôde ser lido.
  static const String dicaReserva =
      'Dica: leia a pergunta com calma e pense no que você já sabe sobre os '
      'hábitos do mosquito e recipientes de água.';

  final AssetBundle _bundle;
  BancoDeDicas? _banco;

  @override
  Future<RespostaAssistente> dicaPara(Pergunta pergunta) async {
    try {
      final banco = await _carregarBanco();
      return banco.dicaPara(pergunta);
    } catch (_) {
      return const RespostaAssistente(
        texto: dicaReserva,
        origem: OrigemResposta.fallback,
      );
    }
  }

  Future<BancoDeDicas> _carregarBanco() async {
    final atual = _banco;
    if (atual != null) {
      return atual;
    }
    final texto = await _bundle.loadString(caminhoAsset);
    final banco = BancoDeDicas.fromJson(
      jsonDecode(texto) as Map<String, dynamic>,
    );
    _banco = banco;
    return banco;
  }
}

/// Banco local de dicas do quiz.
class BancoDeDicas {
  const BancoDeDicas({
    required this.dicaPadrao,
    required this.porCategoria,
    required this.porPergunta,
  });

  /// Cria o banco a partir do conteúdo de `assets/assistente/dicas.json`.
  factory BancoDeDicas.fromJson(Map<String, dynamic> json) {
    return BancoDeDicas(
      dicaPadrao: json['dica_padrao'] as String,
      porCategoria: Map<String, String>.from(
        json['dicas_por_categoria'] as Map<String, dynamic>,
      ),
      porPergunta: Map<String, String>.from(
        json['dicas_por_pergunta'] as Map<String, dynamic>,
      ),
    );
  }

  /// Dica genérica, usada quando não há nada mais específico.
  final String dicaPadrao;

  /// Dicas por categoria. A chave é o nome da categoria no JSON.
  final Map<String, String> porCategoria;

  /// Dicas por pergunta. A chave é o `id` da pergunta.
  final Map<String, String> porPergunta;

  /// Escolhe a dica mais específica disponível para a [pergunta].
  RespostaAssistente dicaPara(Pergunta pergunta) {
    final dica =
        porPergunta[pergunta.id] ?? porCategoria[pergunta.categoria.name];
    if (dica != null) {
      return RespostaAssistente(texto: dica, origem: OrigemResposta.banco);
    }
    return RespostaAssistente(texto: dicaPadrao, origem: OrigemResposta.padrao);
  }
}
