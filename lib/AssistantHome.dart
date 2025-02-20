import 'ResultQuery.dart';
import 'WeatherDetails.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather/weather.dart';

class AssistantHome extends StatefulWidget {
  const AssistantHome(
      {super.key,
      required this.title,
      required this.themeColor,
      required this.fontFamily});

  final String title;
  final Color themeColor;
  final String fontFamily;

  @override
  State<AssistantHome> createState() => _AssistantHomeState();
}

class _AssistantHomeState extends State<AssistantHome> {
  late TextEditingController searchBarCont;
  late Color micColor;
  late bool micIsOn;
  late String title;
  late SpeechToText speech;
  late bool micWorking;
  late bool micHasPermission;
  late bool inListenSession;
  late bool waitingForMic;
  late bool waitingForGPT;
  late bool disableSend;
  late bool disableWeather;
  late String cityName;
  Image? weatherIcon;
  late LocationPermission checkDevicePerm;
  Position? currLocation;
  List<Placemark>? currLocationDetails;
  late WeatherFactory weatherAPI;
  late Weather? currWeatherData;
  late String temp;

  @override
  void initState() {
    super.initState();
    OpenAI.apiKey = "sk-proj-ZJvatCIB6mNyi3evYq4mT3BlbkFJ8CdOY4wvB3pEn7DrZbdA";
    weatherAPI = WeatherFactory("0cf32073e017dfeb08f294640e2bb50d");
    micColor = Colors.white;
    micIsOn = false;
    title = widget.title;
    speech = SpeechToText();
    micWorking = false;
    inListenSession = false;
    disableSend = true;
    cityName = "---";
    waitingForMic = false;
    waitingForGPT = false;
    temp = "--";
    disableWeather = true;
    micHasPermission = true;
    searchBarCont = TextEditingController();
    searchBarCont.addListener(() {
      if (disableSend == false &&
          micIsOn == false &&
          searchBarCont.text.isEmpty) {
        setState(() {
          disableSend = true;
        });
      } else if (disableSend == true &&
          micIsOn == false &&
          searchBarCont.text.isNotEmpty) {
        setState(() {
          disableSend = false;
        });
      }
    });
    getLocationAndWeather();
  }

  Future<OpenAIChatCompletionModel> queryGPT() async {
    return await OpenAI.instance.chat
        .create(model: "gpt-3.5-turbo-0125", messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            searchBarCont.text,
          ),
        ],
        role: OpenAIChatMessageRole.user,
      )
    ]);
  }

  void micState() async {
    if (await speech.hasPermission == false) {
      setState(() {
        micHasPermission = false;
      });
      return;
    }

    bool alreadyInitialized = true;
    if (!micWorking) {
      alreadyInitialized = false;
      setState(() {
        waitingForMic = true;
      });
      micWorking = await speech.initialize(
        onStatus: (status) {
          if (speech.isNotListening && inListenSession == true) {
            setState(() {
              micIsOn = false;
              micColor = Colors.white;
              title = widget.title;
              inListenSession = false;
              if (searchBarCont.text.isNotEmpty) {
                disableSend = false;
              }
            });
          } else if (speech.isListening && inListenSession == false) {
            setState(() {
              micIsOn = true;
              micColor = Colors.red;
              title = "Listening...";
              inListenSession = true;
              if (disableSend == false) {
                disableSend = true;
              }
            });
          }
        },
      );
    }

    if (micWorking && !inListenSession) {
      if (alreadyInitialized == true) {
        setState(() {
          waitingForMic = true;
        });
      }
      await speech.listen(
        onResult: (speechRes) {
          searchBarCont.text = speechRes.recognizedWords;
        },
      );
      setState(() {
        waitingForMic = false;
      });
    } else if (micWorking && inListenSession) {
      setState(() {
        waitingForMic = true;
      });
      if (searchBarCont.text.isEmpty) {
        await speech.cancel();
      } else {
        await speech.stop();
      }
      setState(() {
        waitingForMic = false;
      });
    }
  }

  void getLocationAndWeather() async {
    LocationPermission checkDevicePerm = await Geolocator.checkPermission();
    if (checkDevicePerm == LocationPermission.always ||
        checkDevicePerm == LocationPermission.whileInUse) {
      currLocation = await Geolocator.getCurrentPosition();
      if (currLocation != null) {
        currLocationDetails = await placemarkFromCoordinates(
            currLocation!.latitude, currLocation!.longitude);
      }
      setState(() {
        cityName = currLocationDetails?.first.locality ?? "Chicago";
      });
    } else if (checkDevicePerm == LocationPermission.deniedForever) {
      setState(() {
        cityName = "Chicago";
      });
    } else if (checkDevicePerm == LocationPermission.denied) {
      checkDevicePerm = await Geolocator.requestPermission();

      if (checkDevicePerm == LocationPermission.always ||
          checkDevicePerm == LocationPermission.whileInUse) {
        Position currLocation = await Geolocator.getCurrentPosition();
        List<Placemark> currLocationDetails = await placemarkFromCoordinates(
            currLocation.latitude, currLocation.longitude);
        setState(() {
          cityName = currLocationDetails.first.locality ?? "Chicago";
        });
      } else if (checkDevicePerm == LocationPermission.deniedForever) {
        setState(() {
          cityName = "Chicago";
        });
      }
    }

    currWeatherData = await weatherAPI.currentWeatherByCityName(cityName);
    if (currWeatherData != null) {
      setState(() {
        temp = currWeatherData?.temperature?.fahrenheit.toString() ?? "--";
        if (temp != "--") {
          temp = temp.substring(
              0, temp.indexOf('.') == -1 ? 2 : temp.indexOf('.'));
        }

        weatherIcon =
            Image.asset("icons/${currWeatherData?.weatherIcon ?? "01d"}.png");
        disableWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: widget.themeColor,
          appBar: AppBar(
            backgroundColor: widget.themeColor,
            title: Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: widget.fontFamily,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
            centerTitle: false,
            toolbarHeight: 80,
            actions: [
              if (waitingForGPT || waitingForMic)
                const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: CircularProgressIndicator(color: Colors.white))
            ],
          ),
          body: Stack(children: [
            Center(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 110, 0, 0),
                    child: Column(children: [
                      ElevatedButton(
                          onPressed: disableWeather == true
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => WeatherDetails(
                                                title: cityName,
                                                currWeatherData:
                                                    currWeatherData!,
                                                themeColor: widget.themeColor,
                                                fontFamily: widget.fontFamily,
                                              )));
                                },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(widget.themeColor),
                              elevation: MaterialStateProperty.all(0)),
                          child: weatherIcon == null
                              ? const Icon(Icons.downloading,
                                  size: 100, color: Colors.white)
                              : Hero(tag: 'weather', child: weatherIcon!)),
                      Text(cityName,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: widget.fontFamily,
                              fontSize: 30,
                              fontWeight: FontWeight.bold))
                    ]))),
            Positioned(
                left: 120,
                top: 70,
                child: Text("$temp\u00B0F",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: widget.fontFamily,
                        fontSize: 35,
                        fontWeight: FontWeight.bold))),
            Positioned(
                width: MediaQuery.of(context).size.width,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 30,
                right: 0,
                child: TextField(
                  enabled: waitingForGPT == true ? false : true,
                  cursorColor: Colors.white,
                  controller: searchBarCont,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: widget.fontFamily,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: micHasPermission == false
                            ? null
                            : () {
                                micState();
                              },
                        disabledColor: Colors.grey,
                        iconSize: 30,
                      ),
                      prefixIconColor: micColor,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      hintText: "Search",
                      hintStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_right),
                          disabledColor: Colors.grey,
                          onPressed: disableSend == true
                              ? null
                              : () async {
                                  setState(() {
                                    waitingForGPT = true;
                                  });

                                  OpenAIChatCompletionModel chat =
                                      await queryGPT();
                                  setState(() {
                                    waitingForGPT = false;
                                    searchBarCont.clear();
                                  });
                                  FocusScope.of(context).unfocus();

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ResultQuery(
                                                result: chat,
                                                themeColor: widget.themeColor,
                                                fontFamily: widget.fontFamily,
                                              )));
                                },
                          iconSize: 40),
                      suffixIconColor: Colors.white),
                  onSubmitted: disableSend == true
                      ? null
                      : (submit) async {
                          setState(() {
                            waitingForGPT = true;
                          });

                          OpenAIChatCompletionModel chat = await queryGPT();
                          setState(() {
                            waitingForGPT = false;
                            searchBarCont.clear();
                          });
                          FocusScope.of(context).unfocus();

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResultQuery(
                                        result: chat,
                                        themeColor: widget.themeColor,
                                        fontFamily: widget.fontFamily,
                                      )));
                        },
                ))
          ]),
        ));
  }
}
