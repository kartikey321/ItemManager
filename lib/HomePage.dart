import 'package:blockchain_ex/AppData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController itemCost = new TextEditingController();
  final TextEditingController itemName = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<dynamic> task = Provider.of<AppData>(context).task;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SharedWallet',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Cost of Item"),
              TextField(
                controller: itemCost,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'ItemCost',
                  labelStyle: TextStyle(fontSize: 14),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0),
                ),
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 50,
              ),
              Text("Name of Item"),
              TextField(
                controller: itemName,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: TextStyle(fontSize: 14),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0),
                ),
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 50,
              ),
              MaterialButton(
                onPressed: () {},
                color: Colors.green,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      'ADD',
                      style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
