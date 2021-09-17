import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 2),
    Band(id: '2', name: 'Queen', votes: 4),
    Band(id: '3', name: 'Linkin Park', votes: 5),
    Band(id: '4', name: 'Cigarretes After Sex', votes: 3)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, index) => _bandTile(bands[index])
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand
      ),
    );
  }

  //El guioncito bajo es para privado parece
  Widget _bandTile(Band band) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction){
        print('band name: ${band.name}');
        //Llamar el borrado backend
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text("Delete band", style: TextStyle(color: Colors.white))
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: (){
          print(band.name);
        },
      ),
    );
  }

  addNewBand(){

    final textController = new TextEditingController();

    if(Platform.isIOS){
      //Esto es para IOS porque si lo dejo como esta abajo, no se visualiza como se debe, entonces hay que hacerlo tambien para IOS
      //tener en cuenta esto al desarrollar apps.
      showCupertinoDialog(
        context: context, 
        builder: ( _ ) => CupertinoAlertDialog(
          title: Text('New band name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true, //esto es una accion de IOS 
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text)
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, //esto es una accion de IOS 
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        )
      );
    }


    //Es el promt ese que aparece
    showDialog(
          context: context, 
          builder: (context) => AlertDialog(
            title: Text('New band name: '),
            content: TextField(
              //Es el input para ingresar algo
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text)
              )
            ],
          )
        );
    }
  
  void addBandToList(String name){
    print(name);
    if(name.length > 1){
      this.bands.add( Band(id: DateTime.now().toString(), name: name));
      setState(() {});
    }

    Navigator.pop(context); //Cierra el dialogo

  }


}