import 'dart:convert';

import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/core/contracts/servicos_contrato.dart';
import 'package:dengue_zero/core/fakes/fakes.dart';
import 'package:dengue_zero/features/assistente/data/assistente_service_local.dart';
import 'package:dengue_zero/features/quiz/data/progresso_service_prefs.dart';
import 'package:dengue_zero/features/quiz/data/quiz_service_json.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bundle falso: entrega os textos guardados em memória.
class _BundleFalso extends CachingAssetBundle {
  _BundleFalso(this._arquivos);

  final Map<String, String> _arquivos;

  @override
  Future<ByteData> load(String key) async {
    final texto = _arquivos[key];
    if (texto == null) {
      throw Exception('Asset não encontrado: $key');
    }
    return ByteData.sublistView(utf8.encode(texto));
  }
}

const Pergunta _pergunta = Pergunta(
  id: 'p1',
  enunciado: 'Enunciado',
  alternativas: ['A', 'B'],
  indiceCorreta: 0,
  explicacao: 'Explicação',
  categoria: Categoria.criadouros,
);

final String _jsonDasPerguntas = jsonEncode(<Map<String, Object>>[
  <String, Object>{
    'id': 'p1',
    'enunciado': 'Enunciado',
    'alternativas': <String>['A', 'B'],
    'indiceCorreta': 0,
    'explicacao': 'Explicação',
    'categoria': 'criadouros',
  },
]);

String _jsonDasDicas({
  Map<String, String> porCategoria = const <String, String>{},
  Map<String, String> porPergunta = const <String, String>{},
}) {
  return jsonEncode(<String, Object>{
    'dica_padrao': 'dica padrão',
    'dicas_por_categoria': porCategoria,
    'dicas_por_pergunta': porPergunta,
  });
}

AssistenteServiceLocal _assistenteCom(String json) {
  return AssistenteServiceLocal(
    bundle: _BundleFalso(<String, String>{
      AssistenteServiceLocal.caminhoAsset: json,
    }),
  );
}

void main() {
  group('ProgressoServiceMemoria', () {
    test('soma os pontos', () async {
      final progresso = ProgressoServiceMemoria();

      expect(await progresso.pontosTotais(), 0);
      await progresso.adicionarPontos(30);
      await progresso.adicionarPontos(10);
      expect(await progresso.pontosTotais(), 40);
    });

    test('recusa zero ou negativo', () async {
      final progresso = ProgressoServiceMemoria();

      await expectLater(progresso.adicionarPontos(0), throwsArgumentError);
      await expectLater(progresso.adicionarPontos(-5), throwsArgumentError);
      expect(await progresso.pontosTotais(), 0);
    });
  });

  group('ProgressoServicePrefs', () {
    const progresso = ProgressoServicePrefs();

    test('guarda e soma os pontos', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      expect(await progresso.pontosTotais(), 0);
      await progresso.adicionarPontos(20);
      await progresso.adicionarPontos(10);
      expect(await progresso.pontosTotais(), 30);
    });

    test('lê o total já salvo na chave anônima', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        ProgressoServicePrefs.chavePontos: 50,
      });

      expect(await progresso.pontosTotais(), 50);
    });

    test('recusa zero ou negativo', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await expectLater(progresso.adicionarPontos(0), throwsArgumentError);
    });
  });

  group('QuizServiceJson', () {
    test('lê as perguntas do arquivo', () async {
      final servico = QuizServiceJson(
        bundle: _BundleFalso(<String, String>{
          QuizServiceJson.caminhoAsset: _jsonDasPerguntas,
        }),
      );

      final perguntas = await servico.carregarPerguntas();

      expect(perguntas, hasLength(1));
      expect(perguntas.single.id, 'p1');
      expect(perguntas.single.categoria, Categoria.criadouros);
    });

    test('avisa quando o arquivo não existe', () async {
      final servico = QuizServiceJson(bundle: _BundleFalso(<String, String>{}));

      await expectLater(
        servico.carregarPerguntas(),
        throwsA(isA<ConteudoIndisponivelException>()),
      );
    });

    test('avisa quando o arquivo está vazio', () async {
      final servico = QuizServiceJson(
        bundle: _BundleFalso(<String, String>{
          QuizServiceJson.caminhoAsset: '[]',
        }),
      );

      await expectLater(
        servico.carregarPerguntas(),
        throwsA(isA<ConteudoIndisponivelException>()),
      );
    });
  });

  group('AssistenteServiceLocal', () {
    test('prefere a dica da própria pergunta', () async {
      final assistente = _assistenteCom(
        _jsonDasDicas(
          porCategoria: <String, String>{'criadouros': 'dica da categoria'},
          porPergunta: <String, String>{'p1': 'dica da pergunta'},
        ),
      );

      final resposta = await assistente.dicaPara(_pergunta);

      expect(resposta.texto, 'dica da pergunta');
      expect(resposta.origem, OrigemResposta.banco);
    });

    test('usa a dica da categoria quando a pergunta não tem dica', () async {
      final assistente = _assistenteCom(
        _jsonDasDicas(
          porCategoria: <String, String>{'criadouros': 'dica da categoria'},
        ),
      );

      final resposta = await assistente.dicaPara(_pergunta);

      expect(resposta.texto, 'dica da categoria');
      expect(resposta.origem, OrigemResposta.banco);
    });

    test('usa a dica padrão quando não há nada específico', () async {
      final assistente = _assistenteCom(_jsonDasDicas());

      final resposta = await assistente.dicaPara(_pergunta);

      expect(resposta.texto, 'dica padrão');
      expect(resposta.origem, OrigemResposta.padrao);
    });

    test('usa a dica de reserva quando o banco não pode ser lido', () async {
      final assistente = AssistenteServiceLocal(
        bundle: _BundleFalso(<String, String>{}),
      );

      final resposta = await assistente.dicaPara(_pergunta);

      expect(resposta.texto, AssistenteServiceLocal.dicaReserva);
      expect(resposta.origem, OrigemResposta.fallback);
    });
  });
}
