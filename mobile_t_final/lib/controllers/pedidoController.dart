import 'package:get/get.dart';
import 'package:mobile_t_final/models/pedidoModel.dart';
import '../services/pedido_service.dart';

class PedidoController extends GetxController {
  PedidoService _pedidoService = PedidoService();

  var isLoading = false.obs;
  var pedidos = <PedidoModel>[].obs;
  static PedidoController get pedidoController => Get.find<PedidoController>();

  Future<dynamic> salvar(PedidoModel pedido) async {
    isLoading.value = true;
    var resposta = await _pedidoService.salvarPedido(pedido);
    isLoading.value = false;
    return resposta;
  }

  Future<void> listarPedidos() async {
    isLoading.value = true;
    try {
      var lista = await _pedidoService.listarPedidos();
      if (lista.isNotEmpty) {
        pedidos.assignAll(lista);
      } else {
        pedidos.clear();
      }
    } catch (e) {
      pedidos.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<dynamic> atualizar(PedidoModel pedido) async {
    isLoading.value = true;
    var resposta = await _pedidoService.atualizarPedido(pedido);
    isLoading.value = false;
    return resposta;
  }

  Future<bool> deletar(String id) async {
    isLoading.value = true;
    var sucesso = await _pedidoService.deletarPedido(id);
    isLoading.value = false;
    return sucesso;
  }
}
