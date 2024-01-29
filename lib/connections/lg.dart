import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LGConnection {
  SSHClient? _client;
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;

  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? '192.168.56.101';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      _client = SSHClient(await SSHSocket.connect(_host, int.parse(_port)),
          username: _username, onPasswordRequest: () => _passwordOrKey);
      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }
}
