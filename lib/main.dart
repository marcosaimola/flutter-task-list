import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _todoListController = TextEditingController();
  List _todoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Getsmart Todo List"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _todoListController,
                    decoration: InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(
                            color: Colors.blueAccent
                        )
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("add"),
                  textColor: Colors.white,
                  onPressed: _addTodo,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
                itemCount: _todoList.length,
                itemBuilder: (context,index){
                return CheckboxListTile(
                  onChanged: (c){
                    setState(() {
                      _todoList[index]["ok"] = c;
                    });
                  },
                  title: Text(_todoList[index]["title"]),
                  value: _todoList[index]["ok"],
                  secondary: CircleAvatar(
                    child: Icon(_todoList[index]["ok"] ? Icons.check : Icons.error)
                    ,),
                );
                }
            ),
          )
        ],
      ),
    );
  }

  void _addTodo(){
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoListController.text;
      _todoListController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async{
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async{

    try {
      final file = await _getFile();
      return file.readAsString();
    }
    catch(e) {
      return null;
    }
  }

}
