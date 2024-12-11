import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clienteModel.dart';

class ClienteService {
  dynamic _response;
  String url = "http://localhost:8080/api/clientes";

  ClienteService() {
    _response = "";
  }

  Future<dynamic> salvarCliente(ClienteModel cliente) async {
    try {
      _response = await http.post(
        Uri.parse(url),
        body: json.encode(cliente.toJson()),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (_response.statusCode == 200 || _response.statusCode == 201) {
        return ClienteModel.fromJson(json.decode(_response.body));
      } else {
        return _tratarErroResposta(_response);
      }
    } catch (e) {
      return 'Erro de conexão: ${e.toString()}';
    }
  }

  Future<List<ClienteModel>> listarClientes() async {
    try {
      _response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (_response.statusCode == 200) {
        List<dynamic> jsonListClientes = json.decode(utf8.decode(_response.bodyBytes));
        return jsonListClientes.map((item) => ClienteModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<ClienteModel?> getClienteById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$url/$id'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        return ClienteModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<ClienteModel?> getClienteByCpfCnpj(String cpfCnpj) async {
    try {
      final response = await http.get(
        Uri.parse('$url/cpf/$cpfCnpj'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        return ClienteModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> atualizarCliente(ClienteModel cliente) async {
    if (cliente.idCliente == null) {
      throw ArgumentError("ID do cliente não pode ser nulo ou vazio para atualização.");
    }
    try {
      _response = await http.put(
        Uri.parse("$url/${cliente.idCliente}"),
        body: json.encode(cliente.toJson()),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      );

      if (_response.statusCode == 200 || _response.statusCode == 201) {
        return ClienteModel.fromJson(json.decode(_response.body));
      } else {
        return _tratarErroResposta(_response);
      }
    } catch (e) {
      return 'Erro de conexão: ${e.toString()}';
    }
  }

  Future<bool> deletarCliente(String id) async {
    if (id.isEmpty) {
      throw ArgumentError("ID do Cliente não pode ser vazio ao deletar.");
    }

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
