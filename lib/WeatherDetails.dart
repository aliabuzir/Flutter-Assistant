import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class WeatherDetails extends StatelessWidget {
  const WeatherDetails(
      {super.key,
      required this.title,
      required this.currWeatherData,
      required this.themeColor,
      required this.fontFamily});

  final String title;
  final Weather currWeatherData;
  final Color themeColor;
  final String fontFamily;

  String descriptionFormatter(String? curr) {
    if (curr == null) {
      return "Condition Not Available";
    }

    String retString = "";
    for (int i = 0; i < curr.length; i++) {
      if (i == 0 || curr[i - 1] == ' ') {
        retString += curr[i].toUpperCase();
      } else {
        retString += curr[i];
      }
    }
    return retString;
  }

  Text detailBuilder(String text) {
    return Text(text,
        style: TextStyle(
            color: Colors.white,
            fontFamily: fontFamily,
            fontSize: 27,
            fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: themeColor,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white, size: 30),
              backgroundColor: themeColor,
              title: Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: fontFamily,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
              centerTitle: false,
              toolbarHeight: 80,
            ),
            body: SingleChildScrollView(
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
                        child: Column(children: [
                          Hero(
                              tag: 'weather',
                              child: Container(
                                height: 160,
                                width: 160,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "icons/${currWeatherData.weatherIcon ?? "01d"}.png"),
                                        fit: BoxFit.fill)),
                              )),
                          detailBuilder(descriptionFormatter(
                              currWeatherData.weatherDescription)),
                          const SizedBox(height: 20),
                          detailBuilder(
                              "Temperature: ${currWeatherData.temperature?.fahrenheit.toString().substring(0, currWeatherData.temperature?.fahrenheit.toString().indexOf('.') == -1 ? 2 : currWeatherData.temperature?.fahrenheit.toString().indexOf('.')) ?? "--"}\u00B0F"),
                          detailBuilder(
                              "Wind Speed: ${currWeatherData.windSpeed ?? "--"} MPH"),
                          detailBuilder(
                              "Wind Gust: ${currWeatherData.windGust ?? "--"} MPH"),
                          detailBuilder(
                              "Feels Like: ${currWeatherData.tempFeelsLike?.fahrenheit.toString().substring(0, currWeatherData.tempFeelsLike?.fahrenheit.toString().indexOf('.') == -1 ? 2 : currWeatherData.tempFeelsLike?.fahrenheit.toString().indexOf('.')) ?? "--"}\u00B0F"),
                          detailBuilder(
                              "Humidity: ${currWeatherData.humidity ?? "--"}%"),
                          detailBuilder(
                              "Pressure: ${currWeatherData.pressure ?? "--"} inHG"),
                        ]))))));
  }
}
