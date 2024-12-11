import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedidoModel.dart';

class PedidoService {
  dynamic _response;
  // Como dito, pegamos pedidos pela rota de clientes
  String urlClientes = "http://localhost:8080/api/clientes";
  String url = "http://localhost:8080/api/pedidos";

  PedidoService() {
    _response = "";
  }

  Future<dynamic> salvarPedido(PedidoModel pedido) async {
    try {
      _response = await http.post(
        Uri.parse(url),
        body: json.encode(pedido.toJson()),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (_response.statusCode == 200 || _response.statusCode == 201) {
        return PedidoModel.fromJson(json.decode(_response.body));
      } else {
        return _tratarErroResposta(_response);
      }
    } catch (e) {
      return 'Erro de conexão: ${e.toString()}';
    }
  }

  Future<List<PedidoModel>> listarPedidos() async {
    try {
      _response = await http.get(
        Uri.parse(urlClientes),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (_response.statusCode == 200) {
        List<dynamic> jsonListClientes = json.decode(utf8.decode(_response.bodyBytes));
        List<PedidoModel> pedidos = [];
        for (var cliente in jsonListClientes) {
          int cid = cliente['idCliente'];
          if (cliente['listaPedidos'] != null) {
            for (var pedidoJson in cliente['listaPedidos']) {
              PedidoModel pedido = PedidoModel(
                idPedido: pedidoJson['idPedido'],
                descricaoPedido: pedidoJson['descricaoPedido'],
                statusPedido: pedidoJson['statusPedido'],
                valorTotal: (pedidoJson['valorTotal'] as num).toDouble(),
                clienteId: cid, // Aqui atribuimos o clienteId conforme o cliente atual
              );
              pedidos.add(pedido);
            }
          }
        }
        return pedidos;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<dynamic> atualizarPedido(PedidoModel pedido) async {
    if (pedido.idPedido == null) {
      throw ArgumentError("ID do pedido não pode ser nulo!");
    }
    try {
      _response = await http.put(
        Uri.parse("$url/${pedido.idPedido}"),
        body: json.encode(pedido.toJson()),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (_response.statusCode == 200 || _response.statusCode == 201) {
        return PedidoModel.fromJson(json.decode(_response.body));
      } else {
        return _tratarErroResposta(_response);
      }
    } catch (e) {
      return 'Erro de conexão: ${e.toString()}';
    }
  }

  Future<bool> deletarPedido(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("ID do pedido vazio.");
    }

    try {
      _response = await http.delete(
        Uri.parse("$url/$id"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (_response.statusCode == 200 || _response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  dynamic _tratarErroResposta(http.Response response) {
    final decodedBody = utf8.decode(response.bodyBytes);
    String errorMessage = 'Erro ao processar a requisição';
    try {
      final errorJson = json.decode(decodedBody);
      if (errorJson['message'] != null) {
        errorMessage = errorJson['message'];
      } else if (errorJson['error'] != null) {
        errorMessage = errorJson['error'];
      }
    } catch (e) {
      errorMessage = decodedBody;
    }
    return errorMessage;
  }
}
