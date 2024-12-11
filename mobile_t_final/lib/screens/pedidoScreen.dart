import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/menu_component.dart';
import '../controllers/clienteController.dart';
import '../controllers/pedidoController.dart';
import '../models/clienteModel.dart';
import '../models/pedidoModel.dart';

class PedidoScreen extends StatefulWidget {
  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  var controllerPedido = PedidoController.pedidoController;
  var controllerCliente = ClienteController.clienteController;

  String? _statusSelecionado;
  ClienteModel? _clienteSelecionado;

  final Map<String, String> statusOptions = {
    'PROCESSAMENTO': 'Em Processamento',
    'ENVIADO': 'Enviado',
    'ENTREGUE': 'Entregue',
    'CANCELADO': 'Cancelado',
  };

  @override
  void initState() {
    super.initState();
    // Carrega a lista de clientes ao iniciar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllerCliente.listarClientes();
    });
  }

  void _clearFields() {
    _descricaoController.clear();
    _valorController.clear();
    setState(() {
      _statusSelecionado = null;
      _clienteSelecionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Vamos padronizar a cor para blueAccent
    final borderColor = Colors.blueAccent;
    final labelColor = Colors.blueAccent;
    final buttonColor = Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Pedido',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: buttonColor,
      ),
      drawer: MenuComponent(),
      body: Obx(() {
        if (controllerPedido.isLoading.value || controllerCliente.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo Descrição do Pedido
                      TextFormField(
                        controller: _descricaoController,
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          labelStyle: TextStyle(color: labelColor),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a descrição do Pedido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Dropdown Status
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(color: labelColor),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                        value: _statusSelecionado,
                        hint: Text('Selecione o status'),
                        isExpanded: true,
                        onChanged: (String? novoStatus) {
                          setState(() {
                            _statusSelecionado = novoStatus;
                          });
                        },
                        items: statusOptions.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione o status do Pedido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Campo Valor
                      TextFormField(
                        controller: _valorController,
                        decoration: InputDecoration(
                          labelText: 'Valor',
                          labelStyle: TextStyle(color: labelColor),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o valor do Pedido';
                          }
                          // Converter vírgulas em pontos, caso digitadas.
                          String valorConvertido = value.replaceAll(',', '.');
                          if (double.tryParse(valorConvertido) == null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Dropdown Cliente
                      DropdownButtonFormField<ClienteModel>(
                        decoration: InputDecoration(
                          labelText: 'Cliente',
                          labelStyle: TextStyle(color: labelColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                        value: _clienteSelecionado,
                        hint: Text('Selecione um cliente'),
                        isExpanded: true,
                        onChanged: (ClienteModel? novoCliente) {
                          setState(() {
                            _clienteSelecionado = novoCliente;
                          });
                        },
                        items: controllerCliente.clientes.map((ClienteModel cliente) {
                          return DropdownMenuItem<ClienteModel>(
                            value: cliente,
                            child: Text(cliente.nomeCompleto),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione um cliente';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.0),

                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: TextStyle(fontSize: 16.0),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Garantir que o cliente selecionado tem um idCliente válido
                              if (_clienteSelecionado == null || _clienteSelecionado!.idCliente == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.error, color: Colors.white),
                                        SizedBox(width: 8),
                                        Expanded(child: Text("Selecione um cliente válido.")),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                    margin: EdgeInsets.all(10),
                                  ),
                                );
                                return;
                              }

                              String valorDigitado = _valorController.text.replaceAll(',', '.');
                              double valorTotal = double.parse(valorDigitado);

                              final pedido = PedidoModel(
                                descricaoPedido: _descricaoController.text,
                                statusPedido: _statusSelecionado!,
                                valorTotal: valorTotal,
                                clienteId: _clienteSelecionado!.idCliente!,
                              );


                              var response = await controllerPedido.salvar(pedido);

                              if (response is PedidoModel) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check, color: Colors.white),
                                        SizedBox(width: 8),
                                        Expanded(child: Text("Pedido salvo com sucesso")),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                    margin: EdgeInsets.all(10),
                                  ),
                                );
                                _clearFields();
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
                          child: Text(
                            'Salvar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }),
    );
  }
}
