// Implementações falsas dos contratos.
//
// Servem para desenvolver e testar cada módulo sem depender dos arquivos JSON
// nem do armazenamento do celular.

import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/core/contracts/servicos_contrato.dart';

/// Quiz falso com uma única pergunta.
class QuizServiceFake implements QuizService {
  const QuizServiceFake();

  @override
  Future<List<Pergunta>> carregarPerguntas() async {
    return const [
      Pergunta(
        id: 'fake1',
        enunciado: 'Onde o mosquito da dengue deixa os ovos?',
        alternativas: [
          'Em água parada',
          'Em terra seca',
          'No ar',
          'Em folhas secas',
        ],
        indiceCorreta: 0,
        explicacao: 'Os ovos precisam de água parada para se desenvolver.',
        categoria: Categoria.criadouros,
      ),
    ];
  }
}

/// Progresso guardado só na memória: some quando o app fecha.
class ProgressoServiceMemoria implements ProgressoService {
  int _pontos = 0;

  @override
  Future<int> pontosTotais() async => _pontos;

  @override
  Future<void> adicionarPontos(int pontos) async {
    if (pontos <= 0) {
      throw ArgumentError.value(
        pontos,
        'pontos',
        'pontos deve ser maior que zero',
      );
    }
    _pontos += pontos;
  }
}

/// Assistente falso: devolve sempre a mesma dica.
class AssistenteServiceFake implements AssistenteService {
  const AssistenteServiceFake();

  @override
  Future<RespostaAssistente> dicaPara(Pergunta pergunta) async {
    return const RespostaAssistente(
      texto: 'Dica: pense em onde pode ficar água parada na sua casa.',
      origem: OrigemResposta.padrao,
    );
  }
}
