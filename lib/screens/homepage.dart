import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manas_dalvi_task2/connections/lg.dart';
import 'package:manas_dalvi_task2/screens/orbit.dart';
import 'package:manas_dalvi_task2/screens/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool connectionStatus = false;

  late LGConnection lg;
  @override
  void initState() {
    super.initState();
    lg = LGConnection();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await lg.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Container(
          // alignment: Alignment.center,
          padding: EdgeInsets.only(left: 30, bottom: 30, right: 30),
          // decoration: BoxDecoration(
          //     // color: Colors.grey,
          //     borderRadius: BorderRadius.circular(50)),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        buttonsTextStyle: const TextStyle(color: Colors.white),
                        showCloseIcon: true,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () async {
                          await lg.rebootLG();
                          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctxt) => InfoScreen()));
                        },
                      ).show();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .4,
                      height: 150.h,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.green.withOpacity(0.75),
                              Colors.blue.withOpacity(0.75),
                              // Colors.blue
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          // Image.asset(
                          //   "assets/images/realtime.png",
                          //   // color: Colors.white,
                          //   height: 50,
                          //   width: 50,
                          // ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Reboot LG",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: Colors.white,
                                letterSpacing: .5,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          )
                        ],
                      ),
                    )),
                Bounceable(
                    onTap: () async {
                      await lg.searchPlace("Pune");
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .4,
                      height: 150.h,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.green.withOpacity(0.75),
                              Colors.blue.withOpacity(0.75),
                              // Colors.blue
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // SvgPicture.asset(
                          //   "assets/images/realtime2.svg",
                          //   color: Colors.white,
                          //   height: 50,
                          //   width: 50,
                          // ),
                          SizedBox(
                            width: 20,
                          ),
                          // Image.asset(
                          //   "assets/images/calendar.png",
                          //   // color: Colors.white,
                          //   height: 50,
                          //   width: 50,
                          // ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Move to City",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: Colors.white,
                                letterSpacing: .5,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          )
                        ],
                      ),
                    )),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: Container(
                      width: MediaQuery.of(context).size.width * .4,
                      height: 150.h,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.green.withOpacity(0.75),
                              Colors.blue.withOpacity(0.75),
                              // Colors.blue
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          // Image.asset(
                          //   "assets/images/earthquake2.png",
                          //   // color: Colors.white,
                          //   height: 50,
                          //   width: 50,
                          // ),
                          SizedBox(
                            width: 15,
                          ),
                          Flexible(
                            child: Text(
                              "Orbit",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: .5,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          )
                        ],
                      ),
                    )),
                Bounceable(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => Earthquake1906(),
                      //     ));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .4,
                      height: 150.h,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.green.withOpacity(0.75),
                              Colors.blue.withOpacity(0.75),
                              // Colors.blue
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          // Image.asset(
                          //   "assets/images/earthquake.png",
                          //   // color: Colors.white,
                          //   height: 50,
                          //   width: 50,
                          // ),
                          SizedBox(
                            width: 15,
                          ),
                          Flexible(
                            child: Text(
                              "Open Bubble",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  overflow: TextOverflow.clip,
                                  color: Colors.white,
                                  letterSpacing: .5,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          )
                        ],
                      ),
                    )),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            // Container(
            //   width: MediaQuery.of(context).size.width * .25,
            //   height: 50,
            //   decoration: BoxDecoration(
            //       color: Colors.grey, borderRadius: BorderRadius.circular(12)),
            //   child: GestureDetector(
            //       onTap: () {}, child: Center(child: Text("Visualize it!"))),
            // ),

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
          // color: Colors.red,
        ),
      ),
    );
  }
}
