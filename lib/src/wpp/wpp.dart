// Thanks to https://github.com/wppconnect-team/wa-js

// ignore_for_file: unused_local_variable

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';

class Wpp {
  InAppWebViewController controller;
  Wpp(this.controller);

  /// make sure to call [init] to Initialize Wpp
  Future init() async {
    String latestBuildUrl =
        "https://github.com/wppconnect-team/wa-js/releases/latest/download/wppconnect-wa.js";
    String content = await http.read(Uri.parse(latestBuildUrl));
    Uri uri = Uri.dataFromString(content);
    WhatsappLogger.log("Injecting WPP");
    //await controller.evaluateJavascript(source: content);
    String wppPath = "packages/whatsapp_bot_flutter_mobile/assets/wpp.js";
    await controller.injectCSSFileFromAsset(assetFilePath: wppPath);

    await Future.delayed(const Duration(seconds: 2));
    var result = await controller.evaluateJavascript(
      source: '''typeof window.WPP !== 'undefined' && window.WPP.isReady;''',
    );
    WhatsappLogger.log("WppReady : $result");
    if (result == false) {
      throw "Failed to initialize WPP";
    }
    await controller.evaluateJavascript(
      source: "WPP.chat.defaultSendMessageOptions.createChat = true;",
    );
    await controller.evaluateJavascript(
      source: "WPP.conn.setKeepAlive(true);",
    );
    await controller.evaluateJavascript(
      source: "WPP.config.poweredBy = 'Whatsapp-Bot-Flutter';",
    );
  }
}
