import 'package:dengue_zero/core/contracts/regras_pontuacao.dart';
import 'package:dengue_zero/core/contracts/rotas.dart';
import 'package:dengue_zero/core/servicos.dart';
import 'package:dengue_zero/features/quiz/domain/sorteio_partida.dart';
import 'package:flutter/material.dart';

/// Assistente Local: mini guia de como jogar e de como os pontos são contados.
///
/// Os números do guia vêm de [RegrasPontuacao] e da quantidade real de
/// perguntas do quiz, então o texto acompanha qualquer mudança nas regras.
class ComoJogarPage extends StatefulWidget {
  const ComoJogarPage({super.key});

  @override
  State<ComoJogarPage> createState() => _ComoJogarPageState();
}

class _ComoJogarPageState extends State<ComoJogarPage> {
  /// Quantidade de perguntas de uma partida. Fica nulo até carregar, ou se
  /// falhar.
  int? _totalPerguntas;

  @override
  void initState() {
    super.initState();
    _carregarTotalDePerguntas();
  }

  Future<void> _carregarTotalDePerguntas() async {
    int total;
    try {
      final perguntas = await Servicos.quiz.carregarPerguntas();
      total = SorteioPartida.tamanhoDaPartida(perguntas);
    } catch (_) {
      // Sem o total, o guia mostra os textos sem os números da partida.
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _totalPerguntas = total;
    });
  }

  void _jogar() {
    Navigator.of(context).pushReplacementNamed(Rotas.quiz);
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalPerguntas;
    const pontos = RegrasPontuacao.pontosPorAcerto;
    const excelente = RegrasPontuacao.percentualExcelente;
    const bom = RegrasPontuacao.percentualBom;

    // Exemplo: "(10 de 12)". Vazio enquanto o total não foi carregado.
    String exemplo(int percentual) {
      if (total == null) {
        return '';
      }
      final minimo = RegrasPontuacao.acertosMinimos(percentual, total);
      return ' ($minimo de $total)';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Como Jogar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Apresentacao(),
            const SizedBox(height: 12),
            _Secao(
              icone: Icons.format_list_numbered,
              titulo: 'Passo a passo',
              filhos: [
                _Passo(
                  numero: 1,
                  texto: total == null
                      ? 'Na tela inicial, toque em “Jogar Quiz”. As perguntas '
                            'são sobre criadouros e prevenção.'
                      : 'Na tela inicial, toque em “Jogar Quiz”. Cada partida '
                            'sorteia $total perguntas sobre criadouros e '
                            'prevenção.',
                ),
                const _Passo(
                  numero: 2,
                  texto:
                      'Leia a pergunta e toque na alternativa que você acha '
                      'certa. Só uma está correta e a resposta não pode ser '
                      'trocada.',
                ),
                const _Passo(
                  numero: 3,
                  texto:
                      'Ficou na dúvida? Antes de responder, toque em “Pedir '
                      'Dica”. O assistente dá uma pista sem entregar a '
                      'resposta.',
                ),
                const _Passo(
                  numero: 4,
                  texto:
                      'Depois de responder, o app mostra a alternativa certa '
                      'e uma explicação. Toque em “Próxima Pergunta” para '
                      'continuar.',
                ),
                const _Passo(
                  numero: 5,
                  texto:
                      'Na última pergunta, toque em “Ver Resultado” para '
                      'conferir seus acertos e os pontos da partida.',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Secao(
              icone: Icons.stars,
              titulo: 'Sistema de pontuação',
              filhos: [
                const _Regra(
                  icone: Icons.check_circle,
                  texto: 'Resposta certa: +$pontos pontos.',
                ),
                const _Regra(
                  icone: Icons.cancel,
                  texto: 'Resposta errada: não ganha e não perde pontos.',
                ),
                const _Regra(
                  icone: Icons.lightbulb,
                  texto: 'Pedir dica é grátis: não desconta pontos.',
                ),
                if (total != null)
                  _Regra(
                    icone: Icons.emoji_events,
                    texto:
                        'Máximo por partida: '
                        '${RegrasPontuacao.pontuacaoMaxima(total)} pontos '
                        '($total perguntas × $pontos pontos).',
                  ),
                const _Regra(
                  icone: Icons.shuffle,
                  texto:
                      'A cada partida, as perguntas e a ordem das alternativas '
                      'mudam. Vale jogar de novo!',
                ),
                const _Regra(
                  icone: Icons.loop,
                  texto:
                      'Os pontos de cada partida somam na “Pontuação '
                      'Conquistada” da tela inicial. Jogue de novo para '
                      'acumular mais.',
                ),
                const _Regra(
                  icone: Icons.phone_android,
                  texto:
                      'A pontuação fica guardada só no seu celular, de forma '
                      'anônima.',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Secao(
              icone: Icons.military_tech,
              titulo: 'Resultado da partida',
              filhos: [
                _Regra(
                  icone: Icons.emoji_events,
                  texto:
                      'A partir de $excelente% de acertos'
                      '${exemplo(excelente)}: mandou muito bem!',
                ),
                _Regra(
                  icone: Icons.thumb_up_alt,
                  texto:
                      'A partir de $bom% de acertos${exemplo(bom)}: boa '
                      'noção, falta pouco para gabaritar.',
                ),
                const _Regra(
                  icone: Icons.fitness_center,
                  texto:
                      'Abaixo de $bom% de acertos: hora de treinar. Revise '
                      'as dicas e jogue de novo.',
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _jogar,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Jogar Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho que apresenta o guia.
class _Apresentacao extends StatelessWidget {
  const _Apresentacao();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Card(
      color: esquema.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.smart_toy, size: 40, color: esquema.onPrimaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assistente Local',
                    style: tema.textTheme.titleMedium?.copyWith(
                      color: esquema.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mini guia do DengueZero: veja como jogar o quiz e como '
                    'os pontos são contados. Funciona 100% offline.',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: esquema.onPrimaryContainer,
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

/// Bloco do guia com ícone, título e itens.
class _Secao extends StatelessWidget {
  const _Secao({
    required this.icone,
    required this.titulo,
    required this.filhos,
  });

  final IconData icone;
  final String titulo;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: tema.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...filhos,
          ],
        ),
      ),
    );
  }
}

/// Passo numerado do "Passo a passo".
class _Passo extends StatelessWidget {
  const _Passo({required this.numero, required this.texto});

  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: esquema.primary,
            child: Text(
              '$numero',
              style: tema.textTheme.labelMedium?.copyWith(
                color: esquema.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: tema.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Regra do guia, com um ícone ao lado do texto.
class _Regra extends StatelessWidget {
  const _Regra({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 22, color: tema.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: tema.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
