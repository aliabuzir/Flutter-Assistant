// Start
//
// Name: Ali Abuzir
// Course: CS 378 Spring 2024
//
// Description: This application is an assistant application that allows a user to ask questions about anything
//              and using OpenAI's API uses a LLM to produce a response (Unfortunately real-time data is not produced).
//              Using the dart_openai package OpenAI's API for their LLMs are available to this application. To make
//              search queries easy to type for the user, this application also supports microphone speech to text so
//              the user can speak their question to the LLM. This feature is implemented using the speech_to_text package
//              that has tools that are used to be able to access the device's microphone and to be able to
//              interpret speech and convert it to text. Another feature of the assistant device is that it is able to find
//              the location of the device and what city the device is in and gather weather data about that city. This feature
//              uses 3 packages to accomplish this. The first one is the geolocator package that uses the device's hardware to find
//              its latitude and longitude coordinates. Then given those coordinates, the second package geocoding finds the city name.
//              Then given the city name, the third package weather can be used to get the current weather information in that given city.
//
//              There is a TextField on the bottom portion of the start screen and that is where the input for the AI model goes along with
//              a right arrow to submit the request to the LLM to produce a response on the text provided and then once the response has returned,
//              a new scene appears which the response text. If the user wishes to speak their query, there is a microphone icon button to the left
//              of the text field in which they can speak and the text they spoke appears in the TextField. The microphone icon will turn red to indicate
//              listening as well as the appbar text will say listening. There will be a weather icon, temperature, and city name in the middle of the start
//              screen as well. The temperature is displayed to the top left of the weather icon displaying the temperature in fahrenheit of the city and the
//              name of the city is under the icon. The icon displays the current weather condition as its icon image (i.e. clouds, sun). The icon is clickable
//              and leads to a different scene which displays more current weather conditions about the city (i.e. wind speeds, humidity). When the application
//              first begins, the city name, weather icon, and temperature will display information that signifies that it is loading the data
//              (downloading icon, -- for temperature, and --- for city name), this is shown while the geolocator, geocoding, and weather packages are gathering data
//              asynchronously. Once the information is acquired, the information on the GUI is updated automatically.
//
// NOTE: LOCATION AND MICROPHONE PERMISSIONS ARE REQUIRED. THEY ARE ASKED IN APP. MAKE SURE TO ALLOW.
// NOTE ON ANDROID EMULATOR: THE ANDROID EMULATOR BY DEFAULT DOES NOT USE THE LAPTOPS MIC TO LISTEN, THAT MUST BE TURNED ON IN ANDROID STUDIO SETTINGS.
//                           TO ENABLE: RUN THE EMULATOR ON THE DEVICE, ON THE RUNNING DEVICES TAP, CLICK THE VERTICAL 3 DOT OPTION, GO TO MICROPHONE,
//                           THEN FINALLY ENABLE VIRTUAL MICROPHONE USES HOST AUDIO INPUT.

import 'package:flutter/material.dart';
import 'AssistantHome.dart';

void main() async {
  runApp(const Start());
}

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Assistant",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const AssistantHome(
        title: "Assistant",
        themeColor: Colors.lightBlueAccent,
        fontFamily: "Bebas Neue",
      ),
    );
  }
}
