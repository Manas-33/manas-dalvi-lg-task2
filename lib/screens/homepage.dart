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
                    dialogType: DialogType.success,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ConnectionFlag(
                              status: connectionStatus,
                            )),
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
            // alignment: Alignment.center,
            padding: EdgeInsets.only(left: 30, bottom: 30, right: 30),
            // decoration: BoxDecoration(
            // color: Colors.grey,
            //     borderRadius: BorderRadius.circular(50)),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: FadeInUp(
              duration: Duration(milliseconds: 500),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                // SizedBox(
                //   height: 50,
                // ),
                Image.asset(
                  "assets/images/logo1.png",
                  scale: 3,
                ),
                SizedBox(
                  height: 50,
                ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Bounceable(
                //         onTap: () async {
                //           AwesomeDialog(
                //             context: context,
                //             dialogType: DialogType.warning,
                //             headerAnimationLoop: false,
                //             animType: AnimType.bottomSlide,
                //             title: 'Do you want to reboot the LG rig?',
                //             desc:
                //                 'This will switch off the current session of the rig and reboot the machine',
                //             buttonsTextStyle:
                //                 const TextStyle(color: Colors.white),
                //             showCloseIcon: true,
                //             btnCancelOnPress: () {},
                //             btnOkOnPress: () async {
                //               await lg.rebootLG();
                //               // Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctxt) => InfoScreen()));
                //             },
                //           ).show();
                //         },
                //         child: Container(
                //           width: MediaQuery.of(context).size.width * .4,
                //           height: 150.h,
                //           decoration: BoxDecoration(
                //               gradient: LinearGradient(
                //                 begin: Alignment.centerLeft,
                //                 end: Alignment.centerRight,
                //                 colors: [
                //                   Colors.green.withOpacity(0.75),
                //                   Colors.blue.withOpacity(0.75),
                //                   // Colors.blue
                //                 ],
                //               ),
                //               borderRadius: BorderRadius.circular(12)),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             children: [
                //               SizedBox(
                //                 width: 20,
                //               ),
                //               // Image.asset(
                //               //   "assets/images/realtime.png",
                //               //   // color: Colors.white,
                //               //   height: 50,
                //               //   width: 50,
                //               // ),
                //               SizedBox(
                //                 width: 15,
                //               ),
                //               Text(
                //                 "Reboot LG",
                //                 style: GoogleFonts.openSans(
                //                   textStyle: TextStyle(
                //                     color: Colors.white,
                //                     letterSpacing: .5,
                //                     fontSize: 8.sp,
                //                     fontWeight: FontWeight.w600,
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(
                //                 width: 15,
                //               )
                //             ],
                //           ),
                //         )),
                //     Bounceable(
                //         onTap: () async {
                //           await lg.searchPlace("Pune");
                //         },
                //         child: Container(
                //           width: MediaQuery.of(context).size.width * .4,
                //           height: 150.h,
                //           decoration: BoxDecoration(
                //               gradient: LinearGradient(
                //                 begin: Alignment.centerLeft,
                //                 end: Alignment.centerRight,
                //                 colors: [
                //                   Colors.green.withOpacity(0.75),
                //                   Colors.blue.withOpacity(0.75),
                //                   // Colors.blue
                //                 ],
                //               ),
                //               borderRadius: BorderRadius.circular(12)),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             children: [
                //               // SvgPicture.asset(
                //               //   "assets/images/realtime2.svg",
                //               //   color: Colors.white,
                //               //   height: 50,
                //               //   width: 50,
                //               // ),
                //               SizedBox(
                //                 width: 20,
                //               ),
                //               // Image.asset(
                //               //   "assets/images/calendar.png",
                //               //   // color: Colors.white,
                //               //   height: 50,
                //               //   width: 50,
                //               // ),
                //               SizedBox(
                //                 width: 15,
                //               ),
                //               Text(
                //                 "Move to City",
                //                 style: GoogleFonts.openSans(
                //                   textStyle: TextStyle(
                //                     color: Colors.white,
                //                     letterSpacing: .5,
                //                     fontSize: 8.sp,
                //                     fontWeight: FontWeight.w700,
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(
                //                 width: 15,
                //               )
                //             ],
                //           ),
                //         )),
                //   ],
                // ),
                // SizedBox(
                //   height: 20.h,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Bounceable(
                //         onTap: () async {
                //           await lg
                //               .buildOrbit(
                //                   Orbit.buildOrbit(Orbit.generateOrbitTag()))
                //               .then((value) async {
                //             // await LGConnection().startOrbit();
                //           });
                //         },
                //         child: Container(
                //           width: MediaQuery.of(context).size.width * .4,
                //           height: 150.h,
                //           decoration: BoxDecoration(
                //               gradient: LinearGradient(
                //                 begin: Alignment.centerLeft,
                //                 end: Alignment.centerRight,
                //                 colors: [
                //                   Colors.green.withOpacity(0.75),
                //                   Colors.blue.withOpacity(0.75),
                //                   // Colors.blue
                //                 ],
                //               ),
                //               borderRadius: BorderRadius.circular(12)),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             children: [
                //               SizedBox(
                //                 width: 20,
                //               ),
                //               // Image.asset(
                //               //   "assets/images/earthquake2.png",
                //               //   // color: Colors.white,
                //               //   height: 50,
                //               //   width: 50,
                //               // ),
                //               SizedBox(
                //                 width: 15,
                //               ),
                //               Flexible(
                //                 child: Text(
                //                   "Orbit",
                //                   style: GoogleFonts.openSans(
                //                     textStyle: TextStyle(
                //                       color: Colors.white,
                //                       letterSpacing: .5,
                //                       fontSize: 8.sp,
                //                       fontWeight: FontWeight.w600,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(
                //                 width: 15,
                //               )
                //             ],
                //           ),
                //         )),
                //     Bounceable(
                //         onTap: () async {
                //           await lg.openBalloon(
                //               "Pune", "Pune", "Manas", 240, "description");
                //         },
                //         child: Container(
                //           width: MediaQuery.of(context).size.width * .4,
                //           height: 150.h,
                //           decoration: BoxDecoration(
                //               gradient: LinearGradient(
                //                 begin: Alignment.centerLeft,
                //                 end: Alignment.centerRight,
                //                 colors: [
                //                   Colors.green.withOpacity(0.75),
                //                   Colors.blue.withOpacity(0.75),
                //                   // Colors.blue
                //                 ],
                //               ),
                //               borderRadius: BorderRadius.circular(12)),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             children: [
                //               SizedBox(
                //                 width: 20,
                //               ),
                //               // Image.asset(
                //               //   "assets/images/earthquake.png",
                //               //   // color: Colors.white,
                //               //   height: 50,
                //               //   width: 50,
                //               // ),
                //               SizedBox(
                //                 width: 15,
                //               ),
                //               Flexible(
                //                 child: Text(
                //                   "Open Bubble",
                //                   style: GoogleFonts.openSans(
                //                     textStyle: TextStyle(
                //                       overflow: TextOverflow.clip,
                //                       color: Colors.white,
                //                       letterSpacing: .5,
                //                       fontSize: 8.sp,
                //                       fontWeight: FontWeight.w600,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(
                //                 width: 15,
                //               )
                //             ],
                //           ),
                //         )),
                //   ],
                // ),
                // SizedBox(
                //   height: 20.h,
                // ),
                // Container(
                //   width: MediaQuery.of(context).size.width * .25,
                //   height: 50,
                //   decoration: BoxDecoration(
                //       color: Colors.grey, borderRadius: BorderRadius.circular(12)),
                //   child: GestureDetector(
                //       onTap: () {}, child: Center(child: Text("Visualize it!"))),
                // ),

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
                              color: Color(0XFF99DCBD),
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
                                            color: Color(0XFF1D5C41),
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
                                          fontSize: 4.sp,
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
                        await lg.searchPlace("Pune");
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
                              color: Color(0XFF99DCBD),
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
                                            color: Color(0XFF1D5C41),
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
                                          fontSize: 4.sp,
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
                              color: Color(0XFF99DCBD),
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
                                            color: Color(0XFF1D5C41),
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
                                          fontSize: 4.sp,
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
                            "Pune", "Pune", "Manas", 240, "description");
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
                              color: Color(0XFF99DCBD),
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
                                            color: Color(0XFF1D5C41),
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
                                          fontSize: 4.sp,
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
                // SizedBox(
                //   height: 10.h,
                // ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ));
                    },
                    child: Text("Hello")),
              ]),
            ),
            // color: Colors.red,
          ),
        ),
      ),
    );
  }
}
