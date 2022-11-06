// Thanks to https://github.com/wppconnect-team/wa-js

// ignore_for_file: unused_local_variable

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

class Wpp {
  InAppWebViewController controller;
  Wpp(this.controller);

  /// make sure to call [init] to Initialize Wpp
  Future init() async {
    String latestBuildUrl =
        "https://github.com/wppconnect-team/wa-js/releases/latest/download/wppconnect-wa.js";
    String content = await http.read(Uri.parse(latestBuildUrl));
    Uri uri = Uri.dataFromString(content);
    await controller.injectJavascriptFileFromUrl(urlFile: uri);

    await Future.delayed(const Duration(seconds: 2));
    var result = await controller.evaluateJavascript(
      source: '''typeof window.WPP !== 'undefined' && window.WPP.isReady;''',
    );
    await controller.evaluateJavascript(
        source: "WPP.chat.defaultSendMessageOptions.createChat = true;");
    await controller.evaluateJavascript(source: "WPP.conn.setKeepAlive(true);");
    await controller.evaluateJavascript(
        source: "WPP.config.poweredBy = 'Whatsapp-Bot-Flutter';");
  }
}
