import 'dart:async';
import 'dart:core';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class ConnectionBloc {
  StreamController<bool> connectionStreamController;

  final Connectivity _connectivity;

  ConnectivityResult _currentConnectivityResult;

  ConnectionBloc({@required Connectivity connectivity})
      : _connectivity = connectivity {
    connectionStreamController = StreamController.broadcast();
  }

  Future<void> init() async {
    _currentConnectivityResult = await _connectivity.checkConnectivity();
    _connectivity.onConnectivityChanged.map((event) =>
        connectionStreamController.sink.add(_isConnected(event)));
    return;
  }

  Future<void> checkConnection() async {
    var connection = _isConnected(await _connectivity.checkConnectivity());
    connectionStreamController.sink.add(connection);
    return;
  }

  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  void dispose() {
    connectionStreamController?.close();
  }
}
