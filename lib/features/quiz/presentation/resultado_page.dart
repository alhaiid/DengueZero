import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/core/contracts/regras_pontuacao.dart';
import 'package:dengue_zero/core/contracts/rotas.dart';
import 'package:flutter/material.dart';

/// Tela de resultado do quiz: acertos, pontos ganhos e mensagem de incentivo.
class ResultadoPage extends StatelessWidget {
  const ResultadoPage({super.key, required this.args});

  /// Dados da partida. Fica nulo se a tela for aberta sem argumentos.
  final ResultadoQuizArgs? args;

  void _jogarNovamente(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Rotas.quiz);
  }

  void _voltarParaInicio(BuildContext context) {
    Navigator.of(context).popUntil((rota) => rota.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final dados = args;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado do Quiz'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (dados == null)
              const _SemDados()
            else
              _ResumoDaPartida(dados: dados),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _jogarNovamente(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Jogar Novamente'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _voltarParaInicio(context),
              icon: const Icon(Icons.home),
              label: const Text('Voltar para o Início'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aviso mostrado quando a tela é aberta sem os dados da partida.
class _SemDados extends StatelessWidget {
  const _SemDados();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      children: [
        Icon(Icons.error_outline, size: 56, color: tema.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          'Dados do quiz não encontrados.',
          style: tema.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Ícone, números e mensagem da partida.
class _ResumoDaPartida extends StatelessWidget {
  const _ResumoDaPartida({required this.dados});

  final ResultadoQuizArgs dados;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final faixa = RegrasPontuacao.faixa(
      acertos: dados.acertos,
      total: dados.total,
    );

    final IconData icone;
    final String mensagem;
    switch (faixa) {
      case FaixaDesempenho.excelente:
        icone = Icons.emoji_events;
        mensagem =
            'Mandou muito bem! Você domina as melhores práticas de prevenção '
            'contra o mosquito. Sua casa e comunidade estão em ótimas mãos!';
      case FaixaDesempenho.bom:
        icone = Icons.thumb_up_alt;
        mensagem =
            'Você tem uma boa noção de prevenção e combate aos criadouros. '
            'Que tal revisar algumas dicas do assistente e tentar gabaritar?';
      case FaixaDesempenho.treino:
        icone = Icons.fitness_center;
        mensagem =
            'O combate à dengue é um treino diário. Que tal conferir as dicas '
            'no assistente e refazer o quiz para aprender ainda mais?';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icone, size: 88, color: esquema.primary),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _Indicador(
                rotulo: 'Acertos',
                valor: '${dados.acertos}/${dados.total}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Indicador(rotulo: 'Pontos', valor: '+${dados.pontos}'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          mensagem,
          style: tema.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (dados.pontos > 0) ...[
          const SizedBox(height: 12),
          Text(
            'Os pontos desta partida já foram somados à sua Pontuação '
            'Conquistada.',
            style: tema.textTheme.bodySmall?.copyWith(
              color: esquema.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Número em destaque com um rótulo embaixo.
class _Indicador extends StatelessWidget {
  const _Indicador({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Card(
      color: esquema.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Text(
              valor,
              style: tema.textTheme.headlineMedium?.copyWith(
                color: esquema.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rotulo,
              style: tema.textTheme.titleSmall?.copyWith(
                color: esquema.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
