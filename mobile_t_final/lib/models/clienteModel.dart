class ClienteModel {
  int? idCliente;
  final String nomeCompleto;
  final String cpfCnpj;
  final String numeroTelefone;
  String? endereco;
  List<dynamic> listaPedidos;

  ClienteModel({
    this.idCliente,
    required this.nomeCompleto,
    required this.cpfCnpj,
    required this.numeroTelefone,
    this.endereco,
    required this.listaPedidos,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      idCliente: json['idCliente'] as int?, // Garantir que vem como int
      nomeCompleto: json['nomeCompleto'] as String,
      cpfCnpj: json['cpfCnpj'] as String,
      numeroTelefone: json['numeroTelefone'] as String,
      endereco: json['endereco'] as String? ?? "",
      listaPedidos: json['listaPedidos'] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'idCliente': idCliente,
    'nomeCompleto': nomeCompleto,
    'cpfCnpj': cpfCnpj,
    'numeroTelefone': numeroTelefone,
    'endereco': endereco,
    'listaPedidos': listaPedidos,
  };
}
