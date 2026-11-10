import 'package:dengue_zero/app.dart';
import 'package:dengue_zero/core/servicos.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Servicos.usarImplementacoesReais();
  runApp(const DengueZeroApp());
}
