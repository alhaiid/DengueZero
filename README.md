# DengueZero

App educativo em Flutter sobre o combate ao mosquito da dengue.

Este projeto foi **recriado a partir do `app-release.apk` (versão 1.0.0)** e já
traz três mudanças em relação a ele:

1. **Quiz sem lógica de programação**: saíram as 6 perguntas de algoritmo.
   Ficaram 12 (6 de criadouros e 6 de prevenção).
2. **"Missões de Algoritmo" removido**: módulo, rota, arquivo de missões e
   botão da tela inicial.
3. **"Assistente Local" sem chat**: agora abre o mini guia **Como Jogar**, com
   o passo a passo do quiz e o sistema de pontuação. O botão "Pedir Dica" do
   quiz continua funcionando.

## Novidades da versão 1.2.0

- Banco com **36 perguntas** (18 de criadouros e 18 de prevenção).
- Cada partida **sorteia 12**, sempre 6 de cada tema, em ordem aleatória.
- As alternativas são **embaralhadas** a cada partida, então a resposta certa
  muda de letra.

## Baixar o APK

Link direto da versão mais recente:
https://github.com/alhaiid/DengueZero/releases/latest/download/DengueZero.apk

A cada envio para a branch `main`, o GitHub Actions compila o app e publica um
APK novo em **Releases**.

## Como gerar o APK

### Pelo GitHub, sem instalar nada

Envie o código para a branch `main`. O fluxo **CI** compila e publica o APK em
Releases (e também como artefato **dengue-zero-apk** na execução).

### No computador

Precisa do Flutter 3.47 ou mais novo.

```
flutter pub get
flutter build apk --release
```

O arquivo sai em `build/app/outputs/flutter-apk/app-release.apk`.

### Antes de instalar

Desinstale a versão antiga do celular. O APK novo é assinado com outra chave,
e o Android não deixa instalar por cima.

## Sistema de pontuação

| Situação | Pontos |
| --- | --- |
| Resposta certa | +10 |
| Resposta errada | 0 (não perde pontos) |
| Pedir dica | 0 (não desconta) |
| Máximo por partida | 120 (12 perguntas sorteadas × 10) |

Os pontos de cada partida somam na "Pontuação Conquistada" da tela inicial,
guardada só no celular.

Faixas da tela de resultado: a partir de 80% de acertos, a partir de 50% e
abaixo de 50%.

Tudo isso fica em `lib/core/contracts/regras_pontuacao.dart`. O jogo e o guia
"Como Jogar" leem os números desse arquivo, então basta mudar lá.

## O que veio do APK e o que foi refeito

**Recuperado do APK:** as perguntas e dicas, os textos das telas, os nomes dos
arquivos, classes e rotas, os ícones usados, a chave onde a pontuação é salva,
o identificador do app (`com.example.dengue_zero`) e a versão do Flutter.

**Refeito:** o código Dart, o layout e as cores. Um APK de release guarda só
código compilado, então as telas foram reescritas seguindo os textos e a
estrutura originais, mas não são cópia pixel a pixel.

**Definido nesta versão:** os 10 pontos por acerto e as faixas de 80% e 50%.
Esses números não puderam ser lidos do código compilado.

## Estrutura

```
lib/
  main.dart, app.dart
  core/
    contracts/   modelos, rotas, serviços e regras de pontuação
    fakes/       implementações falsas para desenvolver e testar
    servicos.dart, navegacao.dart, tema/
  features/
    home/        tela inicial
    quiz/        quiz, resultado, sorteio da partida, perguntas e pontuação
    assistente/  guia "Como Jogar", dicas do quiz, privacidade e fontes
assets/
  quiz/perguntas.json      banco de 36 perguntas
  assistente/dicas.json
```

## Qualidade

```
flutter analyze
flutter test
```

Privacidade por design: sem login, sem SDKs de análise e sem anúncios.
