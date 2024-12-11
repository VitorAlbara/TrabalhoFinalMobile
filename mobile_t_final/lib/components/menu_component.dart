import 'package:flutter/material.dart';
import 'package:mobile_t_final/screens/clienteScreen.dart';
import 'package:mobile_t_final/screens/listaClientesScreen.dart';
import 'package:mobile_t_final/screens/listaPedidosScreen.dart';
import 'package:mobile_t_final/screens/pedidoScreen.dart';

import '../screens/homeScreen.dart';

class MenuComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: 50,),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Cadastrar Cliente'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClienteScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Listar Clientes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListaClienteScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Cadastrar Pedido'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PedidoScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart_sharp),
            title: Text('Listar Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListaPedidoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
