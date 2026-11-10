// Testes de tela do app inteiro, usando as implementações falsas
// (uma pergunta só: a certa é "Em água parada").

import 'package:dengue_zero/app.dart';
import 'package:dengue_zero/core/servicos.dart';
import 'package:dengue_zero/features/assistente/presentation/como_jogar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _abrirApp(WidgetTester tester) async {
  // Tela alta: tudo fica visível sem precisar rolar.
  tester.view.physicalSize = const Size(1080, 4800);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const DengueZeroApp());
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

void main() {
  setUp(Servicos.usarFakes);

  testWidgets('a tela inicial tem só o Quiz e o Assistente Local', (
    tester,
  ) async {
    await _abrirApp(tester);

    expect(find.text('0 pts'), findsOneWidget);
    expect(find.text('Quiz DengueZero'), findsOneWidget);
    expect(find.text('Jogar Quiz'), findsOneWidget);
    expect(find.text('Assistente Local'), findsOneWidget);
    expect(find.text('Como Jogar'), findsOneWidget);
    expect(find.textContaining('Missões'), findsNothing);
    expect(find.textContaining('Algoritmo'), findsNothing);
    expect(find.textContaining('Chat'), findsNothing);
  });

  testWidgets('o Assistente Local abre o guia, sem chat', (tester) async {
    await _abrirApp(tester);

    await _tocar(tester, 'Como Jogar');

    expect(find.byType(ComoJogarPage), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Passo a passo'), findsOneWidget);
    expect(find.text('Sistema de pontuação'), findsOneWidget);
    expect(find.text('Resposta certa: +10 pontos.'), findsOneWidget);
    expect(
      find.text('Pedir dica é grátis: não desconta pontos.'),
      findsOneWidget,
    );
    // O quiz falso tem 1 pergunta, então o máximo da partida é 10 pontos.
    expect(
      find.textContaining('Máximo por partida: 10 pontos'),
      findsOneWidget,
    );
    expect(find.text('Resultado da partida'), findsOneWidget);
  });

  testWidgets('o botão do guia leva para o quiz', (tester) async {
    await _abrirApp(tester);
    await _tocar(tester, 'Como Jogar');

    await _tocar(tester, 'Jogar Quiz');

    expect(find.text('Pergunta 1 de 1'), findsOneWidget);
  });

  testWidgets('pedir dica mostra a pista do assistente', (tester) async {
    await _abrirApp(tester);
    await _tocar(tester, 'Jogar Quiz');

    await _tocar(tester, 'Pedir Dica');

    expect(find.text('Dica do Assistente'), findsOneWidget);
    expect(find.textContaining('na sua casa'), findsOneWidget);

    await _tocar(tester, 'Entendi');

    expect(find.text('Dica do Assistente'), findsNothing);
  });

  testWidgets('acertar soma 10 pontos na pontuação conquistada', (
    tester,
  ) async {
    await _abrirApp(tester);
    await _tocar(tester, 'Jogar Quiz');
    expect(find.text('Pergunta 1 de 1'), findsOneWidget);

    await _tocar(tester, 'Em água parada');

    expect(find.text('Resposta certa! +10 pontos'), findsOneWidget);
    expect(find.text('Explicação Pedagógica'), findsOneWidget);

    await _tocar(tester, 'Ver Resultado');

    expect(find.text('Resultado do Quiz'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);

    await _tocar(tester, 'Voltar para o Início');

    expect(find.text('10 pts'), findsOneWidget);
  });

  testWidgets('errar não soma nem tira pontos', (tester) async {
    await _abrirApp(tester);
    await _tocar(tester, 'Jogar Quiz');

    await _tocar(tester, 'No ar');

    expect(find.textContaining('Resposta errada'), findsOneWidget);

    await _tocar(tester, 'Ver Resultado');

    expect(find.text('0/1'), findsOneWidget);
    expect(find.text('+0'), findsOneWidget);

    await _tocar(tester, 'Voltar para o Início');

    expect(find.text('0 pts'), findsOneWidget);
  });

  testWidgets('jogar de novo acumula os pontos das partidas', (tester) async {
    await _abrirApp(tester);
    await _tocar(tester, 'Jogar Quiz');
    await _tocar(tester, 'Em água parada');
    await _tocar(tester, 'Ver Resultado');

    await _tocar(tester, 'Jogar Novamente');
    await _tocar(tester, 'Em água parada');
    await _tocar(tester, 'Ver Resultado');
    await _tocar(tester, 'Voltar para o Início');

    expect(find.text('20 pts'), findsOneWidget);
  });
}
