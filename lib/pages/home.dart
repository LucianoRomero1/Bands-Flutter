import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload){
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }


  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
              ? Icon(Icons.check_circle, color: Colors.blue[300])
              : Icon(Icons.offline_bolt, color: Colors.red)              
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _showGraph(),
            Expanded(
              child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) => _bandTile(bands[index])
              ),
            ),
          ],
        ),
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

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: ( _ ) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete band', style: TextStyle(color: Colors.white))
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: ()=> socketService.socket.emit('vote-band', {'id': band.id})
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
        builder: ( _ ) => AlertDialog(
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
    if(name.length > 1){
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context); //Cierra el dialogo

  }

  Widget _showGraph(){

    Map<String, double> dataMap = new Map();

    if(bands.length > 0){

      bands.forEach((band) {
        dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
      });

      return Container(
        padding: EdgeInsets.only(top: 15),
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          chartType: ChartType.ring,
        )
      );

    }
    return Container(
      padding: EdgeInsets.only(top: 15),
      alignment: Alignment.center,
      child: Text('No hay bandas para mostrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

}