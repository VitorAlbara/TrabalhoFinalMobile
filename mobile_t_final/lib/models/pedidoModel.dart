class PedidoModel {
  int? idPedido;
  final String descricaoPedido;
  final String statusPedido;
  double valorTotal;
  int clienteId;

  PedidoModel({
    this.idPedido,
    required this.descricaoPedido,
    required this.statusPedido,
    required this.valorTotal,
    required this.clienteId,
  });

  // Como o GET de pedidos vem de dentro de clientes (listaPedidos),
  // se precisarmos de fromJson individual, manter, mas não é obrigatório.
  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      idPedido: json['idPedido'] as int?,
      descricaoPedido: json['descricaoPedido'] as String,
      statusPedido: json['statusPedido'] as String,
      valorTotal: (json['valorTotal'] as num).toDouble(),
      clienteId: 0, // Placeholder, se usado isolado. Não é o caso, já que pegamos dos clientes.
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPedido': idPedido,
      'descricaoPedido': descricaoPedido,
      'statusPedido': statusPedido,
      'valorTotal': valorTotal,
      'cliente': {
        'idCliente': clienteId
      }
    };
  }
}
