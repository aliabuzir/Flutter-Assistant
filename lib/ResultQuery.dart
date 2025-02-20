import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';

class ResultQuery extends StatelessWidget {
  const ResultQuery(
      {super.key,
      required this.result,
      required this.themeColor,
      required this.fontFamily});

  final OpenAIChatCompletionModel result;
  final Color themeColor;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: themeColor,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white, size: 30),
            backgroundColor: themeColor,
            title: Text("Response",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: fontFamily,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
            centerTitle: false,
            toolbarHeight: 80,
          ),
          body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(
                result.choices.first.message.content?.first.text ??
                    "Sorry, an error has occurred.",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: fontFamily,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              )),
        ));
  }
}
