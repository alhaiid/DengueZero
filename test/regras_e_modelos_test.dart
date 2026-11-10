import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/core/contracts/regras_pontuacao.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _jsonDePergunta({
  String categoria = 'prevencao',
  int indiceCorreta = 1,
}) {
  return <String, dynamic>{
    'id': 'p1',
    'enunciado': 'Enunciado',
    'alternativas': <dynamic>['A', 'B'],
    'indiceCorreta': indiceCorreta,
    'explicacao': 'Explicação',
    'categoria': categoria,
  };
}

void main() {
  group('Pergunta.fromJson', () {
    test('lê todos os campos', () {
      final pergunta = Pergunta.fromJson(_jsonDePergunta());

      expect(pergunta.id, 'p1');
      expect(pergunta.enunciado, 'Enunciado');
      expect(pergunta.alternativas, <String>['A', 'B']);
      expect(pergunta.explicacao, 'Explicação');
      expect(pergunta.categoria, Categoria.prevencao);
      expect(pergunta.estaCorreta(1), isTrue);
      expect(pergunta.estaCorreta(0), isFalse);
    });

    test('recusa a categoria removida (algoritmo)', () {
      expect(
        () => Pergunta.fromJson(_jsonDePergunta(categoria: 'algoritmo')),
        throwsFormatException,
      );
    });

    test('recusa indiceCorreta fora do intervalo', () {
      expect(
        () => Pergunta.fromJson(_jsonDePergunta(indiceCorreta: 2)),
        throwsFormatException,
      );
    });
  });

  group('RegrasPontuacao', () {
    test('cada acerto vale 10 pontos', () {
      expect(RegrasPontuacao.pontosPorAcerto, 10);
      expect(RegrasPontuacao.pontosDaPartida(0), 0);
      expect(RegrasPontuacao.pontosDaPartida(7), 70);
      expect(RegrasPontuacao.pontuacaoMaxima(12), 120);
    });

    test('faixas de desempenho com 12 perguntas', () {
      FaixaDesempenho faixa(int acertos) {
        return RegrasPontuacao.faixa(acertos: acertos, total: 12);
      }

      expect(faixa(12), FaixaDesempenho.excelente);
      expect(faixa(10), FaixaDesempenho.excelente);
      expect(faixa(9), FaixaDesempenho.bom);
      expect(faixa(6), FaixaDesempenho.bom);
      expect(faixa(5), FaixaDesempenho.treino);
      expect(faixa(0), FaixaDesempenho.treino);
    });

    test('sem perguntas, a faixa é a mais baixa', () {
      expect(
        RegrasPontuacao.faixa(acertos: 0, total: 0),
        FaixaDesempenho.treino,
      );
    });

    test('acertosMinimos acompanha as faixas', () {
      expect(RegrasPontuacao.acertosMinimos(80, 12), 10);
      expect(RegrasPontuacao.acertosMinimos(50, 12), 6);
      expect(RegrasPontuacao.acertosMinimos(80, 1), 1);
    });
  });
}
