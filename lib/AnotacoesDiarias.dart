import 'package:app9anotacoesdiarias/helper/AnotacaoHelper.dart';
import 'package:app9anotacoesdiarias/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AnotacoesDiarias extends StatefulWidget {
  @override
  _AnotacoesDiariasState createState() => _AnotacoesDiariasState();
}

class _AnotacoesDiariasState extends State<AnotacoesDiarias> {
  TextEditingController _titulo = TextEditingController();
  TextEditingController _descricao = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _telaCadastro({Anotacao anotacao}) {
    String textoSalvarAtualizar = "";

    if (anotacao == null) {
      _titulo.clear();
      _descricao.clear();
      textoSalvarAtualizar = "Salvar";
    } else {
      _titulo.text = anotacao.titulo;
      _descricao.text = anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${textoSalvarAtualizar} Anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                      labelText: "Titulo", hintText: "Digite o titulo..."),
                  controller: _titulo,
                  autofocus: true,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a descrição..."),
                  controller: _descricao,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                    Navigator.pop(context);
                  },
                  child: Text(textoSalvarAtualizar)),
            ],
          );
        });
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _titulo.text;
    String descricao = _descricao.text;

    if (anotacaoSelecionada == null) {
      //salvando
      Anotacao anotacao =
      Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else {
      //atualizando
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int result = await _db.atualizarAnotacao(anotacaoSelecionada);
      print("Atualização: $result");
    }

    _titulo.clear();
    _descricao.clear();

    _recuperarAnotacoes();
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = List<Anotacao>();
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = null;
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");
//    var formatador = DateFormat('dd/MM/y H:m:s');
//    var formatador = DateFormat.yMMMMd("pt_BR");
    var formatador = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);
    return dataFormatada;
  }

  _removerAnotacao(int id) async {
      await _db.removerAnotacao(id);
      _recuperarAnotacoes();
  }
  _confirmarExlusao(int id){

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Tem certeza que deseja excluir?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    _removerAnotacao(id);
                    Navigator.pop(context);
                  },
                  child: Text("Confirmar")),
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anotações Diárias"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _anotacoes.length,
                  itemBuilder: (context, index) {
                    final item = _anotacoes[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.titulo),
                        subtitle: Text(
                            "${_formatarData(item.data)} - ${item.descricao}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                _telaCadastro(anotacao: item);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _confirmarExlusao(item.id);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  })),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: () {
            _telaCadastro();
          }),
    );
  }
}
