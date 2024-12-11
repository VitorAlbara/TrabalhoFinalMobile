import 'package:get/get.dart';

import 'controllers/clienteController.dart';
import 'controllers/pedidoController.dart';


class ControllerBinding implements Bindings{
  @override
  void dependencies() {
    Get.lazyPut<ClienteController>(() => ClienteController());
    Get.lazyPut<PedidoController> (() => PedidoController());
  }
}