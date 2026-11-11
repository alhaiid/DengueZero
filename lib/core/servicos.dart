import 'dart:math';

import 'package:dengue_zero/core/contracts/servicos_contrato.dart';
import 'package:dengue_zero/core/fakes/fakes.dart';
import 'package:dengue_zero/features/assistente/data/assistente_service_local.dart';
import 'package:dengue_zero/features/quiz/data/progresso_service_prefs.dart';
import 'package:dengue_zero/features/quiz/data/quiz_service_json.dart';

/// Ponto único de acesso aos serviços do app.
///
/// Começa com as implementações falsas. O `main` troca pelas reais antes de
/// abrir o app; os testes continuam com as falsas.
abstract final class Servicos {
  static QuizService quiz = const QuizServiceFake();
  static ProgressoService progresso = ProgressoServiceMemoria();
  static AssistenteService assistente = const AssistenteServiceFake();

  /// Gerador usado para sortear perguntas e alternativas de cada partida.
  static Random aleatorio = Random();

  /// Usa os arquivos JSON do app e o armazenamento local do celular.
  static void usarImplementacoesReais() {
    quiz = QuizServiceJson();
    progresso = const ProgressoServicePrefs();
    assistente = AssistenteServiceLocal();
    aleatorio = Random();
  }

  /// Volta para as implementações falsas, com a pontuação zerada.
  static void usarFakes() {
    quiz = const QuizServiceFake();
    progresso = ProgressoServiceMemoria();
    assistente = const AssistenteServiceFake();
    aleatorio = Random(0);
  }
}
