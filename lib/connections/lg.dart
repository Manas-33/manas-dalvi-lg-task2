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

  searchPlace(String placeName) async {
    try {
      connectToLG();
      final execResult =
          await _client?.execute('echo "search=$placeName" >/tmp/query.txt');
      return execResult;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  rebootLG() async {
    try {
      connectToLG();

      for (int i = int.parse(_numberOfRigs); i > 0; i--) {
        await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"');
      }
      return null;
    } catch (e) {
      print("An error occurred while executing the command: $e");
      return null;
    }
  }

  buildOrbit(String content) async {
    String localPath = await _localPath;
    File localFile = File('$localPath/Orbit.kml');
    localFile.writeAsString(content);
    try {
      connectToLG();
      await _client?.run("echo '$content' > /var/www/html/Orbit.kml");
      await _client!.execute(
          "echo '\nhttp://lg1:81/Orbit.kml' >> /var/www/html/kmls.txt");
      return await _client!.execute('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      print('Error in building orbit');
      return Future.error(e);
    }
  }

  startOrbit() async {
    try {
      return await _client!.execute('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  stopOrbit() async {
    try {
      return await _client!.execute('echo "exittour=true" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  cleanOrbit() async {
    try {
      return await _client!.execute('echo "" > /tmp/query.txt');
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  openBalloon(
    String name,
    String track,
    String time,
    int height,
    String description,
  ) async {
    int rigs = (int.parse(_numberOfRigs) / 2).floor() + 1;
    String openBalloonKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>$name.kml</name>
	<Style id="purple_paddle">
		<BalloonStyle>
			<text>\$[description]</text>
      <bgColor>4169E11e</bgColor>
		</BalloonStyle>
	</Style>
	<Placemark id="0A7ACC68BF23CB81B354">
		<name>$track</name>
		<Snippet maxLines="0"></Snippet>
		<description><![CDATA[<!-- BalloonStyle background color:
ffffffff
 -->
<table width="400" border="0" cellspacing="0" cellpadding="5">
  <tr>
    <td colspan="2" align="center">
      <img src="https://myapp33bucket.s3.amazonaws.com/logoo.png" alt="picture" width="150" height="150" />
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <h2><font color='#00CC99'>$track</font></h2>
      <h3><font color='#00CC99'>$time</font></h3>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <p><font color="#3399CC">$description</font></p>
    </td>
  </tr>
</table>]]></description>
		<LookAt>
			<longitude>73.8567</longitude>
			<latitude>18.5204</latitude>
			<altitude>0</altitude>
			<heading>0</heading>
			<tilt>0</tilt>
			<range>24000</range>
		</LookAt>
		<styleUrl>#purple_paddle</styleUrl>
		<gx:balloonVisibility>1</gx:balloonVisibility>
		<Point>
			<coordinates>73.8567,18.5204,0</coordinates>
		</Point>
	</Placemark>
</Document>
</kml>
''';
    try {
      connectToLG();
      return await _client!.execute(
          "echo '$openBalloonKML' > /var/www/html/kml/slave_$rigs.kml");
    } catch (e) {
      return Future.error(e);
    }
  }
}
