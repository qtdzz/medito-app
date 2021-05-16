import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';

class ConnectionBloc {
  StreamController<bool> connectionStreamController;

  final Future<bool> Function() _connectivityChecker;

  ConnectionBloc({@required Future<bool> Function() connectivityChecker})
      : _connectivityChecker = connectivityChecker {
    connectionStreamController = StreamController.broadcast();
  }

  Future<bool> checkConnection() async {
    print('checking state');
    var connection = await _connectivityChecker();
    connectionStreamController.sink.add(connection);
    print('adding state $connection');
    return connection;
  }

  void dispose() {
    connectionStreamController?.close();
  }
}
