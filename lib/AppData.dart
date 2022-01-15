import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class AppData extends ChangeNotifier {
  List task = [];
  final String _rpcUrl =
      "https://ropsten.infura.io/v3/311bc290e68a4841a7775feba2c6e96d";
  final String _wsUrl =
      "wss://ropsten.infura.io/ws/v3/311bc290e68a4841a7775feba2c6e96d";
  // final String _rpcUrl = "HTTP://192.168.10.38:7545";
  // final String _wsUrl = "ws://192.168.10.38:7545/";

  final String _privateKey =
      "d8e238a5da15fd8412057e4ab5a7e9ad440aa865ce32c548cc001c4d1ecb0ce0";

  Web3Client? _client;

  String? _abiCode;

  EthereumAddress? _contactaddress;
  EthereumAddress? _ownAddress;
  DeployedContract? _contract;
  ContractFunction? _itemIndex;
  ContractFunction? _items;
  ContractFunction? _createItem;
  ContractFunction? _triggerPayment;
  ContractFunction? _triggerDelivery;
  ContractFunction? _SItem;
  ContractFunction? _supplyChainState;
  ContractEvent? _supplyChainStepEvent;

  Credentials? _credentials;

  AppData() {
    initiateSetup();
  }
  Future<void> initiateSetup() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(Uri.parse(_wsUrl)).cast<String>();
    });
    await getAbi();
    //await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString("src/abis/ItemManager.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contactaddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    print(_contactaddress);
    //print(_abiCode!);
  }

  Future<void> getCredentials() async {
    _credentials = await _client!.credentialsFromPrivateKey(_privateKey);
    _ownAddress = await _credentials!.extractAddress();
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode!, "ItemManager"), _contactaddress!);
    _itemIndex = _contract!.function("itemIndex");
    // _items = _contract!.function("items");
    //_createItem = _contract!.function("createItem");
    ContractFunction createItem1() => _contract!.function('createItem');
    _triggerPayment = _contract!.function("triggerPayment");
    _triggerDelivery = _contract!.function("triggerDelivery");
    // _SItem = _contract!.function("S_Item");
    // _supplyChainState = _contract!.function("SupplyChainState");
    _supplyChainStepEvent = _contract!.event("SupplyChainStep");

    StreamSubscription stream =
        listenEvent(_supplyChainStepEvent!, 1, _contract);

    List<dynamic> res = await _client!.call(
        contract: _contract!,
        function: createItem1(),
        params: ["task", BigInt.from(100)]);
    print(res);
  }

  StreamSubscription listenEvent(
      ContractEvent? _supplyEvent, int take, DeployedContract? _contract) {
    var events = _client!.events(FilterOptions.events(
      contract: _contract!,
      event: _supplyEvent!,
    ));

    if (take != null) {
      events = events.take(take);
    }

    StreamSubscription stream = events.listen((event) {
      final decoded = _supplyEvent.decodeResults(event.topics!, event.data!);

      print(decoded);
    });
    return stream;
  }
}
