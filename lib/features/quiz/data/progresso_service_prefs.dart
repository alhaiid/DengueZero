import 'package:dengue_zero/core/contracts/servicos_contrato.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda a pontuação no armazenamento local do celular.
///
/// Só um número é salvo, sem nenhum dado que identifique a pessoa.
class ProgressoServicePrefs implements ProgressoService {
  const ProgressoServicePrefs();

  /// Chave usada para guardar o total de pontos.
  static const String chavePontos = 'dengue_zero_pontos_anonimos';

  @override
  Future<int> pontosTotais() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(chavePontos) ?? 0;
  }

  @override
  Future<void> adicionarPontos(int pontos) async {
    if (pontos <= 0) {
      throw ArgumentError.value(
        pontos,
        'pontos',
        'pontos deve ser maior que zero',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    final atual = prefs.getInt(chavePontos) ?? 0;
    await prefs.setInt(chavePontos, atual + pontos);
  }
}
