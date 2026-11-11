// Confere os arquivos de conteúdo que vão dentro do app.

import 'dart:convert';
import 'dart:io';

import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/features/assistente/data/assistente_service_local.dart';
import 'package:dengue_zero/features/quiz/domain/sorteio_partida.dart';
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

  test('o banco tem 36 perguntas, 18 de cada categoria', () {
    expect(perguntas, hasLength(36));
    expect(
      perguntas.where((p) => p.categoria == Categoria.criadouros),
      hasLength(18),
    );
    expect(
      perguntas.where((p) => p.categoria == Categoria.prevencao),
      hasLength(18),
    );
  });

  test('com este banco, cada partida tem 12 perguntas', () {
    expect(SorteioPartida.tamanhoDaPartida(perguntas), 12);
  });

  test('não sobrou pergunta de lógica de programação', () {
    expect(textoDasPerguntas.toLowerCase(), isNot(contains('algoritmo')));
    expect(
      perguntas.map((p) => p.id),
      everyElement(isNot(startsWith('algoritmo'))),
    );
  });

  test('ids únicos e quatro alternativas diferentes por pergunta', () {
    expect(perguntas.map((p) => p.id).toSet(), hasLength(perguntas.length));
    for (final pergunta in perguntas) {
      expect(pergunta.alternativas, hasLength(4), reason: pergunta.id);
      expect(pergunta.alternativas.toSet(), hasLength(4), reason: pergunta.id);
    }
  });

  test('enunciados não se repetem', () {
    final enunciados = perguntas.map((p) => p.enunciado.toLowerCase());
    expect(enunciados.toSet(), hasLength(perguntas.length));
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
