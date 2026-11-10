// Modelos compartilhados entre os módulos do DengueZero (contrato).

/// Categorias das perguntas do quiz.
enum Categoria {
  criadouros('Criadouros'),
  prevencao('Prevenção');

  const Categoria(this.rotulo);

  /// Nome exibido na interface.
  final String rotulo;

  /// Converte o texto usado no JSON na categoria correspondente.
  static Categoria fromJson(String valor) {
    for (final categoria in Categoria.values) {
      if (categoria.name == valor) {
        return categoria;
      }
    }
    throw FormatException('Categoria desconhecida: $valor');
  }
}

/// Pergunta de múltipla escolha do quiz.
class Pergunta {
  const Pergunta({
    required this.id,
    required this.enunciado,
    required this.alternativas,
    required this.indiceCorreta,
    required this.explicacao,
    required this.categoria,
  });

  /// Cria a pergunta a partir de um item de `assets/quiz/perguntas.json`.
  factory Pergunta.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final alternativas = List<String>.unmodifiable(
      json['alternativas'] as List<dynamic>,
    );
    final indiceCorreta = json['indiceCorreta'] as int;
    if (indiceCorreta < 0 || indiceCorreta >= alternativas.length) {
      throw FormatException('indiceCorreta fora do intervalo na pergunta $id');
    }
    return Pergunta(
      id: id,
      enunciado: json['enunciado'] as String,
      alternativas: alternativas,
      indiceCorreta: indiceCorreta,
      explicacao: json['explicacao'] as String,
      categoria: Categoria.fromJson(json['categoria'] as String),
    );
  }

  final String id;
  final String enunciado;
  final List<String> alternativas;
  final int indiceCorreta;
  final String explicacao;
  final Categoria categoria;

  /// Indica se a alternativa de posição [indice] é a correta.
  bool estaCorreta(int indice) => indice == indiceCorreta;
}

/// De onde veio o texto devolvido pelo assistente.
enum OrigemResposta {
  /// Dica específica encontrada no banco local.
  banco,

  /// Dica genérica do banco local.
  padrao,

  /// Texto de reserva, usado quando o banco local não pôde ser lido.
  fallback,
}

/// Texto devolvido pelo assistente local.
class RespostaAssistente {
  const RespostaAssistente({required this.texto, required this.origem});

  final String texto;
  final OrigemResposta origem;
}

/// Argumentos enviados para a rota de resultado do quiz.
class ResultadoQuizArgs {
  const ResultadoQuizArgs({
    required this.acertos,
    required this.total,
    required this.pontos,
  });

  /// Quantidade de respostas certas na partida.
  final int acertos;

  /// Quantidade de perguntas da partida.
  final int total;

  /// Pontos ganhos na partida.
  final int pontos;
}
