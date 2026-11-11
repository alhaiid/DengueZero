import 'package:dengue_zero/core/contracts/rotas.dart';
import 'package:dengue_zero/core/navegacao.dart';
import 'package:dengue_zero/core/servicos.dart';
import 'package:flutter/material.dart';

/// Tela inicial: pontuação acumulada e entrada para os módulos.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  int _pontos = 0;

  @override
  void initState() {
    super.initState();
    _carregarPontos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rota = ModalRoute.of(context);
    if (rota != null) {
      observadorDeRotas.subscribe(this, rota);
    }
  }

  @override
  void dispose() {
    observadorDeRotas.unsubscribe(this);
    super.dispose();
  }

  /// Chamado quando a tela inicial volta a ficar visível.
  @override
  void didPopNext() {
    _carregarPontos();
  }

  Future<void> _carregarPontos() async {
    int pontos;
    try {
      pontos = await Servicos.progresso.pontosTotais();
    } catch (_) {
      // Sem acesso ao armazenamento, mantém o valor que já está na tela.
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _pontos = pontos;
    });
  }

  void _navegarPara(String rota) {
    Navigator.of(context).pushNamed(rota);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DengueZero'),
        actions: [
          IconButton(
            tooltip: 'Privacidade',
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: () => _navegarPara(Rotas.privacidade),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CartaoPontos(pontos: _pontos),
            const SizedBox(height: 24),
            Text('Módulos de Ação', style: tema.textTheme.titleLarge),
            const SizedBox(height: 12),
            _CardModulo(
              icone: Icons.psychology,
              titulo: 'Quiz DengueZero',
              descricao:
                  'Partidas de 12 perguntas sorteadas sobre Criadouros e '
                  'Prevenção. Teste seus conhecimentos e peça dicas!',
              rotuloBotao: 'Jogar Quiz',
              iconeBotao: Icons.play_arrow,
              onPressed: () => _navegarPara(Rotas.quiz),
            ),
            const SizedBox(height: 12),
            _CardModulo(
              icone: Icons.smart_toy,
              titulo: 'Assistente Local',
              descricao:
                  'Mini guia de como jogar: passo a passo do quiz, dicas e '
                  'sistema de pontuação. 100% offline.',
              rotuloBotao: 'Como Jogar',
              iconeBotao: Icons.menu_book,
              onPressed: () => _navegarPara(Rotas.assistente),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _navegarPara(Rotas.privacidade),
              icon: const Icon(Icons.shield_outlined),
              label: const Text('Privacidade e Fontes'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão com o total de pontos acumulados.
class _CartaoPontos extends StatelessWidget {
  const _CartaoPontos({required this.pontos});

  final int pontos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Card(
      color: esquema.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.stars, size: 44, color: esquema.onPrimaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pontuação Conquistada',
                    style: tema.textTheme.titleMedium?.copyWith(
                      color: esquema.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pontos pts',
                    style: tema.textTheme.headlineMedium?.copyWith(
                      color: esquema.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão de entrada de um módulo do app.
class _CardModulo extends StatelessWidget {
  const _CardModulo({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.rotuloBotao,
    required this.iconeBotao,
    required this.onPressed,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final String rotuloBotao;
  final IconData iconeBotao;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: esquema.secondaryContainer,
                  foregroundColor: esquema.onSecondaryContainer,
                  child: Icon(icone),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(titulo, style: tema.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(descricao, style: tema.textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(iconeBotao),
              label: Text(rotuloBotao),
            ),
          ],
        ),
      ),
    );
  }
}
