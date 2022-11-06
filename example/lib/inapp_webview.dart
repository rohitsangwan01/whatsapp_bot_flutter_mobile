import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:whatsapp_bot_example/home_controller.dart';

class InAppWebViewPage extends GetView<HomeController> {
  const InAppWebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest:
            URLRequest(url: WebUri.uri(Uri.parse("https://web.whatsapp.com/"))),
        onLoadStop: (cntrl, url) {
          controller.webViewController.value = cntrl;
        },
        onConsoleMessage: (controller, consoleMessage) {
          Get.log(consoleMessage.message);
        },
        initialSettings: InAppWebViewSettings(
          preferredContentMode: UserPreferredContentMode.DESKTOP,
          useShouldOverrideUrlLoading: true,
          clearCache: true,
          cacheEnabled: false,
          mediaPlaybackRequiresUserGesture: false,
          userAgent:
              'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; en-US; rv:1.9.0.4) Gecko/20100101 Firefox/60.0',
          javaScriptEnabled: true,
        ),
      ),
    );
  }
}
