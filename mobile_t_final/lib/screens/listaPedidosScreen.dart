import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_t_final/models/pedidoModel.dart';

import '../components/menu_component.dart';
import '../controllers/pedidoController.dart';
import '../controllers/clienteController.dart';
import '../models/clienteModel.dart';

class ListaPedidoScreen extends StatefulWidget {
  @override
  State<ListaPedidoScreen> createState() => _ListaPedidoScreenState();
}

class _ListaPedidoScreenState extends State<ListaPedidoScreen> {
  var controllerPedido = PedidoController.pedidoController;
  var controllerCliente = ClienteController.clienteController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Primeiro carregar clientes para poder exibir nomes
      controllerCliente.listarClientes().then((_) {
        controllerPedido.listarPedidos();
      });
    });
  }

  void _showUpdateDialog(PedidoModel pedido) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _descricaoController =
    TextEditingController(text: pedido.descricaoPedido);
    final TextEditingController _valorController =
    TextEditingController(text: pedido.valorTotal.toString());
    final List<String> statusOptions = ['PROCESSAMENTO', 'ENVIADO', 'ENTREGUE', 'CANCELADO'];

    String? _statusSelecionado = pedido.statusPedido;
    // Encontrar o cliente atual a partir do clienteId do pedido
    ClienteModel? clienteAtual = controllerCliente.clientes.firstWhereOrNull((c) => c.idCliente == pedido.clienteId);
    ClienteModel? _clienteSelecionado = clienteAtual;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Atualizar Pedido"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a descrição do Pedido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    value: _statusSelecionado,
                    items: statusOptions.map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      _statusSelecionado = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione o status do Pedido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _valorController,
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o valor do Pedido';
                      }
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Dropdown para selecionar o cliente
                  DropdownButtonFormField<ClienteModel>(
                    decoration: InputDecoration(
                      labelText: 'Cliente',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    value: _clienteSelecionado,
                    isExpanded: true,
                    items: controllerCliente.clientes.map((cliente) {
                      return DropdownMenuItem<ClienteModel>(
                        value: cliente,
                        child: Text(cliente.nomeCompleto),
                      );
                    }).toList(),
                    onChanged: (novoCliente) {
                      _clienteSelecionado = novoCliente;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione um cliente';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  double valorConvertido = double.parse(_valorController.text.replaceAll(',', '.'));
                  var pedidoAtualizado = PedidoModel(
                    idPedido: pedido.idPedido,
                    descricaoPedido: _descricaoController.text,
                    statusPedido: _statusSelecionado!,
                    valorTotal: valorConvertido,
                    clienteId: _clienteSelecionado!.idCliente!,
                  );

                  var response = await controllerPedido.atualizar(pedidoAtualizado);
                  if (response is PedidoModel) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(child: Text("Pedido atualizado com sucesso")),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                        margin: EdgeInsets.all(10),
                      ),
                    );
                    controllerPedido.listarPedidos();
                    Navigator.of(context).pop();
                  } else if (response is String) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(child: Text(response)),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                        margin: EdgeInsets.all(10),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(child: Text("Ocorreu um erro inesperado.")),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                        margin: EdgeInsets.all(10),
                      ),
                    );
                  }
                }
              },
              child: Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(int idPedido) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Deletar Pedido"),
          content: Text("Tem certeza que deseja deletar este pedido?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                var sucesso = await controllerPedido.deletar(idPedido.toString());
                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(child: Text("Pedido deletado com sucesso")),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                      margin: EdgeInsets.all(10),
                    ),
                  );
                  controllerPedido.listarPedidos();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(child: Text("Erro ao deletar o Pedido")),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                      margin: EdgeInsets.all(10),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text("Deletar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Pedidos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: MenuComponent(),
      body: Obx(() {
        if (controllerPedido.isLoading.value || controllerCliente.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controllerPedido.pedidos.isEmpty) {
          return Center(
            child: Text(
              "Nenhum pedido registrado.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: controllerPedido.pedidos.length,
            itemBuilder: (context, index) {
              final pedido = controllerPedido.pedidos[index];
              // Buscar o cliente correspondente
              final cliente = controllerCliente.clientes.firstWhereOrNull((c) => c.idCliente == pedido.clienteId);
              final clienteNome = cliente != null ? cliente.nomeCompleto : "Desconhecido";

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pedido.descricaoPedido,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text("Status: ${pedido.statusPedido}", style: TextStyle(fontSize: 16, color: Colors.blue)),
                      SizedBox(height: 4),
                      Text("Valor: R\$ ${pedido.valorTotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text("Cliente: $clienteNome", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showUpdateDialog(pedido);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (pedido.idPedido != null) {
                                _confirmDelete(pedido.idPedido!);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
