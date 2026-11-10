import 'package:flutter/widgets.dart';

/// Observador de rotas do app.
///
/// A tela inicial usa este observador para recarregar a pontuação sempre que
/// volta a ficar visível (por exemplo, depois de uma partida do quiz).
final RouteObserver<ModalRoute<void>> observadorDeRotas =
    RouteObserver<ModalRoute<void>>();
