import 'package:get/get.dart';
import '../models/clienteModel.dart';
import '../services/cliente_service.dart';

class ClienteController extends GetxController {
  ClienteService _clienteService = ClienteService();

  var isLoading = false.obs;
  var clientes = <ClienteModel>[].obs;
  static ClienteController get clienteController => Get.find<ClienteController>();

  Future<dynamic> salvar(ClienteModel cliente) async {
    isLoading.value = true;
    var resposta = await _clienteService.salvarCliente(cliente);
    isLoading.value = false;
    return resposta; // Obx já atualiza por conta do isLoading e clientes
  }

  Future<void> listarClientes() async {
    isLoading.value = true;
    try {
      var lista = await _clienteService.listarClientes();
      if (lista.isNotEmpty) {
        clientes.assignAll(lista);
      } else {
        clientes.clear();
      }
    } catch (e) {
      clientes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<dynamic> atualizar(ClienteModel cliente) async {
    isLoading.value = true;
    var resposta = await _clienteService.atualizarCliente(cliente);
    isLoading.value = false;
    return resposta;
  }

  Future<bool> deletar(String id) async {
    isLoading.value = true;
    var sucesso = await _clienteService.deletarCliente(id);
    isLoading.value = false;
    return sucesso;
  }
}
