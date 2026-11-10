import 'package:dengue_zero/core/contracts/rotas.dart';
import 'package:dengue_zero/features/assistente/presentation/como_jogar_page.dart';
import 'package:dengue_zero/features/assistente/presentation/privacidade_page.dart';
import 'package:flutter/material.dart';

/// Rotas do módulo Assistente Local.
final Map<String, WidgetBuilder> rotasAssistente = <String, WidgetBuilder>{
  Rotas.assistente: (context) => const ComoJogarPage(),
  Rotas.privacidade: (context) => const PrivacidadePage(),
};
