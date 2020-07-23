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
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

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
            child: RefreshIndicator(onRefresh: _refresh,
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _todoList.length,
                itemBuilder: buildItem
            ),)
          )
        ],
      ),
    );
  }


  Widget buildItem (context,index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          child: Icon(Icons.delete_forever, color: Colors.white,),
          alignment: Alignment(-0.9, 0.0),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        onChanged: (c){
          setState(() {
            _todoList[index]["ok"] = c;
            _saveData();
          });
        },
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_todoList[index]["ok"] ? Icons.check : Icons.error)
          ,),
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);
          _saveData();

          // showing the snackBar
          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida."),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _todoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));

        setState(() {
          _todoList.sort((a,b){
          if(a["ok"] &&  !b["ok"]) return 1;
          else if(!a["ok"] && b["ok"]) return -1;
          else return 0;
        });
          _saveData();
    });

  return null;
  }


  void _addTodo(){
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoListController.text;
      _todoListController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
      _saveData();
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

  @override
  void initState() {
    super.initState();

    _readData().then((value) {
      setState(() {
        _todoList = json.decode(value);
      });
    });
  }
}
