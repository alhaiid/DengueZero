import 'package:dengue_zero/core/contracts/modelos.dart';
import 'package:dengue_zero/core/contracts/regras_pontuacao.dart';
import 'package:dengue_zero/core/contracts/rotas.dart';
import 'package:dengue_zero/core/servicos.dart';
import 'package:flutter/material.dart';

/// Tela do quiz: uma pergunta por vez, com dica e explicação.
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Pergunta> _perguntas = const [];
  bool _carregando = true;
  bool _falhou = false;
  int _indiceAtual = 0;
  int? _selecionada;
  int _acertos = 0;
  bool _buscandoDica = false;
  bool _finalizando = false;
  final ScrollController _rolagem = ScrollController();

  @override
  void initState() {
    super.initState();
    _iniciarQuiz();
  }

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  Future<void> _iniciarQuiz() async {
    List<Pergunta> perguntas;
    try {
      perguntas = await Servicos.quiz.carregarPerguntas();
    } catch (_) {
      perguntas = const [];
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _perguntas = perguntas;
      _indiceAtual = 0;
      _selecionada = null;
      _acertos = 0;
      _carregando = false;
      _falhou = perguntas.isEmpty;
    });
  }

  void _tentarNovamente() {
    setState(() {
      _carregando = true;
      _falhou = false;
    });
    _iniciarQuiz();
  }

  void _selecionarAlternativa(int indice) {
    if (_selecionada != null) {
      return;
    }
    final acertou = _perguntas[_indiceAtual].estaCorreta(indice);
    setState(() {
      _selecionada = indice;
      if (acertou) {
        _acertos++;
      }
    });
    // Depois que a explicação aparece, rola a tela até ela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_rolagem.hasClients) {
        return;
      }
      _rolagem.animateTo(
        _rolagem.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pedirDica() async {
    if (_buscandoDica) {
      return;
    }
    setState(() {
      _buscandoDica = true;
    });
    String texto;
    try {
      final resposta = await Servicos.assistente.dicaPara(
        _perguntas[_indiceAtual],
      );
      texto = resposta.texto;
    } catch (_) {
      texto =
          'Desculpe, o assistente está indisponível no momento. '
          'Tente novamente mais tarde.';
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _buscandoDica = false;
    });
    await _exibirDialogoDica(texto);
  }

  Future<void> _exibirDialogoDica(String texto) {
    return showDialog<void>(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          icon: const Icon(Icons.lightbulb),
          title: const Text('Dica do Assistente'),
          content: Text(texto),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(contextoDialogo).pop(),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _proximaPergunta() async {
    if (_indiceAtual < _perguntas.length - 1) {
      setState(() {
        _indiceAtual++;
        _selecionada = null;
      });
      if (_rolagem.hasClients) {
        _rolagem.jumpTo(0);
      }
      return;
    }
    if (_finalizando) {
      return;
    }
    setState(() {
      _finalizando = true;
    });
    final acertos = _acertos;
    final total = _perguntas.length;
    final pontos = RegrasPontuacao.pontosDaPartida(acertos);
    if (pontos > 0) {
      try {
        await Servicos.progresso.adicionarPontos(pontos);
      } catch (_) {
        // Se não der para salvar, o resultado é mostrado mesmo assim.
      }
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(
      Rotas.resultadoQuiz,
      arguments: ResultadoQuizArgs(
        acertos: acertos,
        total: total,
        pontos: pontos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz DengueZero')),
      body: SafeArea(child: _construirCorpo(context)),
    );
  }

  Widget _construirCorpo(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_falhou) {
      return _FalhaAoCarregar(onTentarNovamente: _tentarNovamente);
    }

    final tema = Theme.of(context);
    final pergunta = _perguntas[_indiceAtual];
    final total = _perguntas.length;
    final numero = _indiceAtual + 1;
    final selecionada = _selecionada;
    final respondida = selecionada != null;
    final ultima = numero == total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            controller: _rolagem,
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pergunta $numero de $total',
                      style: tema.textTheme.titleMedium,
                    ),
                  ),
                  Chip(
                    label: Text(pergunta.categoria.rotulo),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: numero / total,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 20),
              Text(pergunta.enunciado, style: tema.textTheme.titleLarge),
              const SizedBox(height: 16),
              for (var i = 0; i < pergunta.alternativas.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OpcaoAlternativa(
                    letra: String.fromCharCode(65 + i),
                    texto: pergunta.alternativas[i],
                    estado: _estadoDaAlternativa(pergunta, i, selecionada),
                    onTap: respondida ? null : () => _selecionarAlternativa(i),
                  ),
                ),
              if (selecionada != null)
                _CartaoExplicacao(
                  acertou: pergunta.estaCorreta(selecionada),
                  explicacao: pergunta.explicacao,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: respondida
              ? FilledButton.icon(
                  onPressed: _finalizando ? null : _proximaPergunta,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(ultima ? 'Ver Resultado' : 'Próxima Pergunta'),
                )
              : OutlinedButton.icon(
                  onPressed: _buscandoDica ? null : _pedirDica,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Pedir Dica'),
                ),
        ),
      ],
    );
  }

  _EstadoAlternativa _estadoDaAlternativa(
    Pergunta pergunta,
    int indice,
    int? selecionada,
  ) {
    if (selecionada == null) {
      return _EstadoAlternativa.disponivel;
    }
    if (pergunta.estaCorreta(indice)) {
      return _EstadoAlternativa.correta;
    }
    if (indice == selecionada) {
      return _EstadoAlternativa.errada;
    }
    return _EstadoAlternativa.descartada;
  }
}

/// Como uma alternativa aparece na tela.
enum _EstadoAlternativa {
  /// Ainda pode ser escolhida.
  disponivel,

  /// É a resposta certa (mostrada depois de responder).
  correta,

  /// Foi escolhida e está errada.
  errada,

  /// Não foi escolhida e não é a certa.
  descartada,
}

/// Botão de uma alternativa da pergunta.
class _OpcaoAlternativa extends StatelessWidget {
  const _OpcaoAlternativa({
    required this.letra,
    required this.texto,
    required this.estado,
    required this.onTap,
  });

  final String letra;
  final String texto;
  final _EstadoAlternativa estado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;

    final Color fundo;
    final Color destaque;
    final Color corTexto;
    final IconData? icone;
    switch (estado) {
      case _EstadoAlternativa.disponivel:
        fundo = esquema.surfaceContainerLow;
        destaque = esquema.outline;
        corTexto = esquema.onSurface;
        icone = null;
      case _EstadoAlternativa.correta:
        fundo = esquema.primaryContainer;
        destaque = esquema.primary;
        corTexto = esquema.onPrimaryContainer;
        icone = Icons.check_circle;
      case _EstadoAlternativa.errada:
        fundo = esquema.errorContainer;
        destaque = esquema.error;
        corTexto = esquema.onErrorContainer;
        icone = Icons.cancel;
      case _EstadoAlternativa.descartada:
        fundo = esquema.surface;
        destaque = esquema.outlineVariant;
        corTexto = esquema.onSurfaceVariant;
        icone = null;
    }

    return Material(
      color: fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: destaque, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Text(
                letra,
                style: tema.textTheme.titleMedium?.copyWith(
                  color: destaque,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  texto,
                  style: tema.textTheme.bodyLarge?.copyWith(color: corTexto),
                ),
              ),
              if (icone != null) ...[
                const SizedBox(width: 8),
                Icon(icone, color: destaque),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Mostra se a resposta está certa e a explicação da pergunta.
class _CartaoExplicacao extends StatelessWidget {
  const _CartaoExplicacao({required this.acertou, required this.explicacao});

  final bool acertou;
  final String explicacao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final pontos = RegrasPontuacao.pontosPorAcerto;
    return Card(
      color: esquema.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              acertou
                  ? 'Resposta certa! +$pontos pontos'
                  : 'Resposta errada. A alternativa certa está destacada.',
              style: tema.textTheme.titleMedium?.copyWith(
                color: esquema.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Explicação Pedagógica',
              style: tema.textTheme.labelLarge?.copyWith(
                color: esquema.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              explicacao,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: esquema.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aviso mostrado quando as perguntas não puderam ser carregadas.
class _FalhaAoCarregar extends StatelessWidget {
  const _FalhaAoCarregar({required this.onTentarNovamente});

  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: tema.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Não foi possível carregar as perguntas.',
              style: tema.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
