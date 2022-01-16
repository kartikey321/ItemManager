import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

typedef TransferEvent = void Function(
    EthereumAddress from, EthereumAddress to, BigInt value);

class AppData extends ChangeNotifier {
  List task = [];

  final String _rpcUrl =
      "https://ropsten.infura.io/v3/311bc290e68a4841a7775feba2c6e96d";
  final String _wsUrl =
      "wss://ropsten.infura.io/ws/v3/311bc290e68a4841a7775feba2c6e96d";
  // final String _rpcUrl = "HTTP://192.168.10.38:7545";
  // final String _wsUrl = "ws://192.168.10.38:7545/";

  final String _privateKey =
      "e9235a64810e830b0336c8d8bac16c22433a1e70e84cee50d0cb9cb4d8255176";

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
  int? _networkId;

  Credentials? _credentials;

  AppData() {
    initiateSetup();
  }
  Future<void> initiateSetup() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(Uri.parse(_wsUrl)).cast<String>();
    });
    await getAbi();
    await getCredentials();
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
    _networkId = await _client!.getNetworkId();
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode!, "ItemManager"), _contactaddress!);
    _itemIndex = _contract!.function("itemIndex");
    // _items = _contract!.function("items");
    _createItem = _contract!.function("createItem");

    _triggerPayment = _contract!.function("triggerPayment");
    _triggerDelivery = _contract!.function("triggerDelivery");
    // _SItem = _contract!.function("S_Item");
    // _supplyChainState = _contract!.function("SupplyChainState");
    _supplyChainStepEvent = _contract!.event("SupplyChainStep");

    StreamSubscription stream =
        listenEvent(_supplyChainStepEvent!, 1, _contract);

    String res1 = await sendTransact(_createItem, ["item1", BigInt.from(100)]);
    //  print(await sendTransact(_triggerPayment, [BigInt.zero]));
    print(res1);

    // List<dynamic> res = await _client!.call(
    //     contract: _contract!,
    //     function: _createItem!,
    //     params: ["task", BigInt.from(100)]);
    // print(res);
  }

  Future<String> sendTransact(
      ContractFunction? function, List<dynamic> params) async {
    String res1 = await _client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: function!,
        parameters: params,
        from: _ownAddress,
      ),
      chainId: _networkId,
    );
    final info = await _client!.getTransactionByHash(res1);
    final result = await _client!.callRaw(
      sender: info!.from,
      contract: info!.to!,
      data: info!.input,
    );
    print(result);
    return res1;
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

    return events.listen((event) {
      final decoded = _supplyEvent.decodeResults(event.topics!, event.data!);

      final from = decoded[0] as EthereumAddress;
      final to = decoded[1] as EthereumAddress;
      final value = decoded[2] as BigInt;

      print('$from');
      print('$to');
      print('$value');
    });
  }

  Future<void> dispose() async {
    await _client!.dispose();
  }
}
