import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manas_dalvi_task2/connections/lg.dart';
import 'package:manas_dalvi_task2/screens/connection_flag.dart';
import 'package:manas_dalvi_task2/screens/orbit.dart';
import 'package:manas_dalvi_task2/screens/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool connectionStatus = false;

  late LGConnection lg;

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _sshPortController.text = prefs.getString('sshPort') ?? '';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', _ipController.text);
    }
    if (_usernameController.text.isNotEmpty) {
      await prefs.setString('username', _usernameController.text);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    if (_sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', _sshPortController.text);
    }
    if (_rigsController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', _rigsController.text);
    }
  }

  @override
  void initState() {
    super.initState();
    lg = LGConnection();
    _loadSettings();
    _connectToLG();

    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 800,
      ),
      vsync: this,
    );
    super.initState();
  }

  Future<void> _connectToLG() async {
    bool? result = await lg.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  late AnimationController _controller;

  bool isClicked = false;

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _sshPortController.dispose();
    _rigsController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 0, 25, 69), actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: IconButton(
              iconSize: 50,
              onPressed: () {
                // Setting icon animation
                // according isClicked variable
                if (isClicked) {
                  _controller.forward();
                  AwesomeDialog(
                    context: context,
                    animType: AnimType.scale,
                    dialogType: DialogType.info,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextField(
                          controller: _ipController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.computer),
                            labelText: 'IP address',
                            hintText: 'Enter Master IP',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'LG Username',
                            hintText: 'Enter your username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: 'LG Password',
                            hintText: 'Enter your password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _sshPortController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.settings_ethernet),
                            labelText: 'SSH Port',
                            hintText: '22',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _rigsController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.memory),
                            labelText: 'No. of LG rigs',
                            hintText: 'Enter the number of rigs',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.green),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            await _saveSettings();
                            // TODO 6: Initalize SSH Instance and call connectToLG() function
                            // SSH ssh = SSH();
                            bool? result = await lg.connectToLG();
                            print(result);
                            if (result == true) {
                              setState(() {
                                connectionStatus = true;
                              });
                              ToastService.showSuccessToast(
                                context,
                                length: ToastLength.medium,
                                expandedHeight: 100,
                                message: "This is a success toast 🥂!",
                              );
                              print('Connected to LG successfully');
                            } else if (result == false || result == null) {
                              ToastService.showSuccessToast(
                                context,
                                length: ToastLength.medium,
                                expandedHeight: 100,
                                message: "This is a warning toast!",
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cast,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'CONNECT TO LG',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.green),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            // TODO 7: Initialize SSH and execute the demo command and test
                            //Re-initialization of the SSH instance to avoid errors for beginners

                            var execResult = await lg.searchPlace("India");
                            if (execResult != null) {
                              print('Command executed successfully');
                            } else {
                              print('Failed to execute command');
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cast,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'SEND COMMAND TO LG',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    title: 'This is Ignored',
                    desc: 'This is also Ignored',
                  ).show();
                } else {
                  _controller.reverse();
                }
                // Changing the value
                // of isClicked variable
                isClicked = !isClicked;
              },
              icon: AnimatedIcon(
                  icon: AnimatedIcons.list_view,
                  color: Colors.white,
                  // providing controller
                  // to the AnimatedIcon
                  progress: _controller),
            ),
          ),
        ),
      ]),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 0, 25, 69),
          padding: const EdgeInsets.all(40.0),
          child: Container(
            padding: EdgeInsets.only(left: 30, bottom: 30, right: 30),

            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: FadeInUp(
              duration: Duration(milliseconds: 500),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Image.asset(
                  "assets/images/logo1.png",
                  scale: 3,
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Bounceable(
                      onTap: () async {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          headerAnimationLoop: false,
                          animType: AnimType.bottomSlide,
                          title: 'Do you want to reboot the LG rig?',
                          desc:
                              'This will switch off the current session of the rig and reboot the machine',
                          buttonsTextStyle:
                              const TextStyle(color: Colors.white),
                          showCloseIcon: true,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            await lg.rebootLG();
                            // Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctxt) => InfoScreen()));
                          },
                        ).show();
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        color: Color(0XFF99DCBD),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                          50,
                        )),
                        child: Container(
                          height: 55.w,
                          width: MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 108, 225, 233),
                              borderRadius: BorderRadius.circular(
                                12.h,
                              )),
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                    height: 137.w,
                                    width: 168.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 23.h,
                                      vertical: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/images/img_group_2.png",
                                        ),
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/images/reboot.png",
                                      height: 50.w,
                                      width: 40.h,
                                      alignment: Alignment.centerRight,
                                      color: Color.fromARGB(255, 14, 67, 110),
                                    )),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 14.h,
                                    top: 14.w,
                                    right: 153.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 130.h,
                                        child: Text(
                                          "Reboot LG",
                                          style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                            overflow: TextOverflow.clip,
                                            color: Color.fromARGB(
                                                255, 14, 67, 110),
                                            letterSpacing: .5,
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.w600,
                                          )),
                                        ),
                                      ),
                                      SizedBox(height: 4.w),
                                      Text(
                                        "Reboot the Liquid Galaxy rig",
                                        style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                          overflow: TextOverflow.clip,
                                          color: Colors.black87,
                                          letterSpacing: .5,
                                          fontSize: 5.sp,
                                          fontWeight: FontWeight.w500,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Bounceable(
                      onTap: () async {
                        await lg.searchPlace("Mumbai");
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        color: Color(0XFF99DCBD),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                          50,
                        )),
                        child: Container(
                          height: 55.w,
                          width: MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 108, 225, 233),
                              borderRadius: BorderRadius.circular(
                                12.h,
                              )),
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                    height: 137.w,
                                    width: 168.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 23.h,
                                      vertical: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/images/img_group_2.png",
                                        ),
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/images/city.png",
                                      height: 100.w,
                                      width: 80.h,
                                      // alignment: Alignment.centerRight,
                                    )),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 14.h,
                                    top: 14.w,
                                    right: 153.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 130.h,
                                        child: Text(
                                          "Go to city",
                                          style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                            overflow: TextOverflow.clip,
                                            color: Color.fromARGB(
                                                255, 14, 67, 110),
                                            letterSpacing: .5,
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.w600,
                                          )),
                                        ),
                                      ),
                                      SizedBox(height: 4.w),
                                      Text(
                                        "Move to Mumbai the city of dreams",
                                        style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                          overflow: TextOverflow.clip,
                                          color: Colors.black87,
                                          letterSpacing: .5,
                                          fontSize: 5.sp,
                                          fontWeight: FontWeight.w500,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Bounceable(
                      onTap: () async {
                        await lg
                            .buildOrbit(
                                Orbit.buildOrbit(Orbit.generateOrbitTag()))
                            .then((value) async {
                          // await LGConnection().startOrbit();
                        });
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        color: Color(0XFF99DCBD),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                          50,
                        )),
                        child: Container(
                          height: 55.w,
                          width: MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 108, 225, 233),
                              borderRadius: BorderRadius.circular(
                                12.h,
                              )),
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                    height: 137.w,
                                    width: 168.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 23.h,
                                      vertical: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/images/img_group_2.png",
                                        ),
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/images/orbit.png",
                                      height: 50.w,
                                      width: 40.h,
                                      alignment: Alignment.centerRight,
                                      color: Color.fromARGB(255, 14, 67, 110),
                                    )),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 14.h,
                                    top: 14.w,
                                    right: 153.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 130.h,
                                        child: Text(
                                          "Start Orbit",
                                          style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                            overflow: TextOverflow.clip,
                                            color: Color.fromARGB(
                                                255, 14, 67, 110),
                                            letterSpacing: .5,
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.w600,
                                          )),
                                        ),
                                      ),
                                      SizedBox(height: 4.w),
                                      Text(
                                        "Start orbiting around the city",
                                        style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                          overflow: TextOverflow.clip,
                                          color: Colors.black87,
                                          letterSpacing: .5,
                                          fontSize: 5.sp,
                                          fontWeight: FontWeight.w500,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Bounceable(
                      onTap: () async {
                        await lg.openBalloon(
                            "Mumbai",
                            "Mumbai",
                            "- Manas Dalvi",
                            240,
                            "Mumbai is the financial, commercial, and entertainment capital of India. It is also one of the world's top ten centers of commerce in terms of global financial flow. Mumbai is located on the west coast of India, and it is the country's most populous city. Mumbai is known for its film production, and it is also home to the Hindi film industry, known as Bollywood.");
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        color: Color(0XFF99DCBD),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                          50,
                        )),
                        child: Container(
                          height: 55.w,
                          width: MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 108, 225, 233),
                              borderRadius: BorderRadius.circular(
                                12.h,
                              )),
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                    height: 137.w,
                                    width: 168.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 23.h,
                                      vertical: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/images/img_group_2.png",
                                        ),
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/images/pop.png",
                                      height: 50.w,
                                      width: 40.h,
                                      alignment: Alignment.centerRight,
                                    )),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 14.h,
                                    top: 14.w,
                                    right: 153.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 130.h,
                                        child: Text(
                                          "Open Balloon",
                                          style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                            overflow: TextOverflow.clip,
                                            color: Color.fromARGB(
                                                255, 14, 67, 110),
                                            letterSpacing: .5,
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.w600,
                                          )),
                                        ),
                                      ),
                                      SizedBox(height: 4.w),
                                      Text(
                                        "Show balloon in Liquid Galaxy rig",
                                        style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                          overflow: TextOverflow.clip,
                                          color: Colors.black87,
                                          letterSpacing: .5,
                                          fontSize: 5.sp,
                                          fontWeight: FontWeight.w500,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
              ]),
            ),
            // color: Colors.red,
          ),
        ),
      ),
    );
  }
}
