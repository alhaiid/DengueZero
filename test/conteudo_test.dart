// Confere os arquivos de conteúdo que vão dentro do app.

import 'dart:convert';
import 'dart:io';

import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/features/assistente/data/assistente_service_local.dart';
import 'package:dengue_zero/features/quiz/data/quiz_service_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String textoDasPerguntas;
  late List<Pergunta> perguntas;
  late BancoDeDicas dicas;

  setUpAll(() {
    textoDasPerguntas = File(QuizServiceJson.caminhoAsset).readAsStringSync();
    perguntas = QuizServiceJson.interpretarPerguntas(textoDasPerguntas);
    dicas = BancoDeDicas.fromJson(
      jsonDecode(File(AssistenteServiceLocal.caminhoAsset).readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  test('o quiz tem 12 perguntas, 6 de cada categoria', () {
    expect(perguntas, hasLength(12));
    expect(
      perguntas.where((p) => p.categoria == Categoria.criadouros),
      hasLength(6),
    );
    expect(
      perguntas.where((p) => p.categoria == Categoria.prevencao),
      hasLength(6),
    );
  });

  test('não sobrou pergunta de lógica de programação', () {
    expect(textoDasPerguntas.toLowerCase(), isNot(contains('algoritmo')));
    expect(
      perguntas.map((p) => p.id),
      everyElement(isNot(startsWith('algoritmo'))),
    );
  });

  test('ids únicos e quatro alternativas por pergunta', () {
    expect(perguntas.map((p) => p.id).toSet(), hasLength(perguntas.length));
    for (final pergunta in perguntas) {
      expect(pergunta.alternativas, hasLength(4), reason: pergunta.id);
    }
  });

  test('toda pergunta tem dica própria no banco do assistente', () {
    for (final pergunta in perguntas) {
      expect(dicas.porPergunta, contains(pergunta.id));
      expect(dicas.dicaPara(pergunta).origem, OrigemResposta.banco);
    }
  });

  test('o banco de dicas não tem mais conteúdo de algoritmo', () {
    expect(dicas.porCategoria.keys, isNot(contains('algoritmo')));
    expect(
      dicas.porPergunta.keys,
      everyElement(isNot(startsWith('algoritmo'))),
    );
  });
}
