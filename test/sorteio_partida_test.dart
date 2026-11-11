import 'dart:math';

import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/features/quiz/domain/sorteio_partida.dart';
import 'package:flutter_test/flutter_test.dart';

Pergunta _pergunta(String id, Categoria categoria, {int indiceCorreta = 1}) {
  return Pergunta(
    id: id,
    enunciado: 'Enunciado $id',
    alternativas: ['$id-a', '$id-b', '$id-c', '$id-d'],
    indiceCorreta: indiceCorreta,
    explicacao: 'Explicação $id',
    categoria: categoria,
  );
}

List<Pergunta> _banco({int porCategoria = 18}) {
  return [
    for (var i = 0; i < porCategoria; i++)
      _pergunta('c$i', Categoria.criadouros),
    for (var i = 0; i < porCategoria; i++)
      _pergunta('p$i', Categoria.prevencao),
  ];
}

void main() {
  group('Pergunta.embaralhada', () {
    test('mantém a mesma resposta certa e as mesmas alternativas', () {
      final original = _pergunta('x', Categoria.criadouros);
      for (var semente = 0; semente < 50; semente++) {
        final nova = original.embaralhada(Random(semente));

        expect(nova.id, original.id);
        expect(nova.enunciado, original.enunciado);
        expect(nova.explicacao, original.explicacao);
        expect(nova.categoria, original.categoria);
        expect(nova.alternativas, unorderedEquals(original.alternativas));
        expect(nova.alternativas[nova.indiceCorreta], 'x-b');
      }
    });

    test('a resposta certa aparece em todas as posições', () {
      final original = _pergunta('x', Categoria.criadouros);
      final aleatorio = Random(42);
      final posicoes = <int>{
        for (var i = 0; i < 200; i++)
          original.embaralhada(aleatorio).indiceCorreta,
      };

      expect(posicoes, {0, 1, 2, 3});
    });
  });

  group('SorteioPartida.montar', () {
    test('sorteia 12 perguntas, 6 de cada tema, sem repetir', () {
      for (var semente = 0; semente < 30; semente++) {
        final partida = SorteioPartida.montar(_banco(), Random(semente));

        expect(partida, hasLength(12));
        expect(partida.map((p) => p.id).toSet(), hasLength(12));
        expect(
          partida.where((p) => p.categoria == Categoria.criadouros),
          hasLength(6),
        );
        expect(
          partida.where((p) => p.categoria == Categoria.prevencao),
          hasLength(6),
        );
      }
    });

    test('a resposta certa continua sendo reconhecida', () {
      final partida = SorteioPartida.montar(_banco(), Random(7));

      for (final pergunta in partida) {
        final correta = pergunta.alternativas[pergunta.indiceCorreta];
        expect(correta, '${pergunta.id}-b');
      }
    });

    test('partidas diferentes trazem combinações diferentes', () {
      final aleatorio = Random(3);
      final combinacoes = <String>{
        for (var i = 0; i < 20; i++)
          (SorteioPartida.montar(_banco(), aleatorio).map((p) => p.id).toList()
                ..sort())
              .join(','),
      };

      expect(combinacoes.length, greaterThan(1));
    });

    test('a ordem das perguntas também é sorteada', () {
      final aleatorio = Random(11);
      final primeiras = <String>{
        for (var i = 0; i < 20; i++)
          SorteioPartida.montar(_banco(), aleatorio).first.id,
      };

      expect(primeiras.length, greaterThan(1));
    });

    test('com poucas perguntas, usa todas as disponíveis', () {
      final banco = [
        _pergunta('c0', Categoria.criadouros),
        _pergunta('c1', Categoria.criadouros),
        _pergunta('p0', Categoria.prevencao),
      ];

      final partida = SorteioPartida.montar(banco, Random(1));

      expect(partida.map((p) => p.id), unorderedEquals(['c0', 'c1', 'p0']));
    });

    test('tamanhoDaPartida acompanha o banco', () {
      expect(SorteioPartida.tamanhoDaPartida(_banco()), 12);
      expect(SorteioPartida.tamanhoDaPartida(_banco(porCategoria: 2)), 4);
      expect(SorteioPartida.tamanhoDaPartida(const []), 0);
    });
  });
}
