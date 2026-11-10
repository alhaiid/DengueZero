import 'package:dengue_zero/core/contracts/rotas.dart';
import 'package:dengue_zero/core/navegacao.dart';
import 'package:dengue_zero/core/tema/app_tema.dart';
import 'package:dengue_zero/features/assistente/assistente_modulo.dart';
import 'package:dengue_zero/features/home/home_page.dart';
import 'package:dengue_zero/features/quiz/quiz_modulo.dart';
import 'package:flutter/material.dart';

/// Raiz do app: tema e rotas de todos os módulos.
class DengueZeroApp extends StatelessWidget {
  const DengueZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DengueZero',
      debugShowCheckedModeBanner: false,
      theme: AppTema.claro,
      navigatorObservers: [observadorDeRotas],
      initialRoute: Rotas.home,
      routes: {
        Rotas.home: (context) => const HomePage(),
        ...rotasQuiz,
        ...rotasAssistente,
      },
    );
  }
}
