import 'package:flutter/material.dart';

/// Compromissos de privacidade do app e fontes oficiais do conteúdo.
class PrivacidadePage extends StatelessWidget {
  const PrivacidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade e Fontes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: esquema.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 36,
                          color: esquema.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Privacidade por Design & Fontes Oficiais',
                            style: tema.textTheme.titleMedium?.copyWith(
                              color: esquema.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Seus dados pertencem a você. O DengueZero foi '
                      'construído para proteger sua privacidade integralmente.',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: esquema.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Compromissos de Privacidade',
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const _ItemPrivacidade(
              icone: Icons.person_off_outlined,
              titulo: 'Zero Coleta de Dados Pessoais',
              descricao:
                  'Não pedimos nem guardamos seu nome, e-mail, idade, escola, '
                  'telefone ou localização.',
            ),
            const _ItemPrivacidade(
              icone: Icons.lock_outline,
              titulo: 'Sem Login ou Cadastro',
              descricao:
                  'Você joga e aprende sem precisar criar contas ou senhas. '
                  'Nada sai do seu dispositivo.',
            ),
            const _ItemPrivacidade(
              icone: Icons.block,
              titulo: 'Sem Anúncios ou Rastreamento',
              descricao:
                  'Não utilizamos SDKs de publicidade, redes de anúncios nem '
                  'ferramentas de análise comportamental '
                  '(analytics/trackers).',
            ),
            const _ItemPrivacidade(
              icone: Icons.phone_android,
              titulo: 'Armazenamento 100% Local',
              descricao:
                  'Sua pontuação conquistada no Quiz é mantida de forma '
                  'anônima exclusivamente na memória interna do seu celular.',
            ),
            const _ItemPrivacidade(
              icone: Icons.wifi_off,
              titulo: 'Assistente Educativo Offline',
              descricao:
                  'As dicas e o guia do assistente funcionam a partir de um '
                  'banco local, sem consultar servidores externos.',
            ),
            const SizedBox(height: 24),
            Text(
              'Fontes Oficiais & Base Científica',
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const _ItemFonte(
              titulo: 'Ministério da Saúde do Brasil',
              descricao:
                  'Campanhas oficiais de combate ao Aedes aegypti e Guia de '
                  'Manejo Clínico da Dengue.',
            ),
            const _ItemFonte(
              titulo: 'Organização Pan-Americana da Saúde (OPAS/OMS)',
              descricao:
                  'Diretrizes internacionais de vigilância epidemiológica e '
                  'controle de arboviroses.',
            ),
            const _ItemFonte(
              titulo: 'Fiocruz (Fundação Oswaldo Cruz)',
              descricao:
                  'Pesquisas sobre o ciclo reprodutivo do vetor, virologia e '
                  'ações de eliminação mecânica de criadouros.',
            ),
            const SizedBox(height: 24),
            Card(
              color: esquema.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: esquema.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aviso Importante de Saúde: O aplicativo DengueZero '
                        'possui finalidade puramente educativa. Não faz '
                        'diagnósticos e não indica medicamentos. Em caso de '
                        'sintomas, procure sempre uma Unidade de Saúde '
                        '(UBS/UPA).',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: esquema.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Um compromisso de privacidade: ícone, título e descrição.
class _ItemPrivacidade extends StatelessWidget {
  const _ItemPrivacidade({
    required this.icone,
    required this.titulo,
    required this.descricao,
  });

  final IconData icone;
  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone, color: Theme.of(context).colorScheme.primary),
      title: Text(titulo),
      subtitle: Text(descricao),
    );
  }
}

/// Uma fonte oficial do conteúdo do app.
class _ItemFonte extends StatelessWidget {
  const _ItemFonte({required this.titulo, required this.descricao});

  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.menu_book,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(titulo),
      subtitle: Text(descricao),
    );
  }
}
