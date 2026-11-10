import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/core/contracts/rotas.dart';
import 'package:dengue_zero/features/quiz/presentation/quiz_page.dart';
import 'package:dengue_zero/features/quiz/presentation/resultado_page.dart';
import 'package:flutter/material.dart';

/// Rotas do módulo Quiz.
final Map<String, WidgetBuilder> rotasQuiz = <String, WidgetBuilder>{
  Rotas.quiz: (context) => const QuizPage(),
  Rotas.resultadoQuiz: (context) {
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    return ResultadoPage(
      args: argumentos is ResultadoQuizArgs ? argumentos : null,
    );
  },
};
