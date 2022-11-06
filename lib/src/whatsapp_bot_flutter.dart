import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/login_helper.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';
import 'package:whatsapp_bot_flutter_mobile/src/model/qr_code_image.dart';
import 'package:whatsapp_bot_flutter_mobile/src/wpp/wpp.dart';
import 'package:whatsapp_bot_flutter_mobile/whatsapp_bot_flutter_mobile.dart';

class WhatsappBotFlutterMobile {
  /// [connect] method will open WhatsappWeb in headless webView and connect to the whatsapp
  /// or we can pass a controller of inAppWebView, but we have to make sure that we should keep
  /// that controller alive
  static Future<WhatsappClient?> connect({
    int qrCodeWaitDurationSeconds = 60,
    Function(String qrCodeUrl, Uint8List? qrCodeImage)? onQrCode,
    Function(ConnectionEvent)? onConnectionEvent,
    Duration? connectionTimeout = const Duration(seconds: 20),
    InAppWebViewController? inAppWebViewController,
  }) async {
    HeadlessInAppWebView? headlessInAppWebView;
    try {
      onConnectionEvent?.call(ConnectionEvent.initializing);
      onConnectionEvent?.call(ConnectionEvent.connectingChrome);
      InAppWebViewController? controller;

      if (inAppWebViewController != null) {
        controller = inAppWebViewController;
      } else {
        var data = await _getHeadlessModeData();
        controller = data[0];
        headlessInAppWebView = data[1];
      }
      if (controller == null) {
        throw "Failed to connect to  webView";
      }
      await Wpp(controller).init();
      onConnectionEvent?.call(ConnectionEvent.waitingForLogin);
      await waitForLogin(
        controller,
        onConnectionEvent: onConnectionEvent,
        (QrCodeImage qrCodeImage, int attempt) {
          if (qrCodeImage.base64Image != null && qrCodeImage.urlCode != null) {
            Uint8List? imageBytes;
            try {
              String? base64Image = qrCodeImage.base64Image
                  ?.replaceFirst("data:image/png;base64,", "");
              imageBytes = base64Decode(base64Image!);
            } catch (e) {
              WhatsappLogger.log(e);
            }
            onQrCode?.call(qrCodeImage.urlCode!, imageBytes);
          }
        },
        waitDurationSeconds: qrCodeWaitDurationSeconds,
      );

      return WhatsappClient(
        controller: controller,
        headlessInAppWebView: headlessInAppWebView,
      );
    } catch (e) {
      WhatsappLogger.log(e.toString());
      headlessInAppWebView?.dispose();
      rethrow;
    }
  }

  /// to run webView in headless mode and connect with it
  static Future _getHeadlessModeData() async {
    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://web.whatsapp.com/")),
      androidOnPermissionRequest: (controller, origin, resources) async {
        return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT);
      },
      onConsoleMessage: (controller, consoleMessage) {
        WhatsappLogger.log(consoleMessage.message);
      },
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
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
    await webView.run();
    Completer<InAppWebViewController> completer = Completer();
    webView.onLoadStop = (controller, url) async {
      // check if whatsapp web redirected us to the wrong mobile version of whatsapp
      if (!url.toString().contains("web.whatsapp.com")) {
        throw "Failed to load WhatsappWeb , please try again or clear cache of application";
      }
      WhatsappLogger.log(url.toString());
      if (!completer.isCompleted) completer.complete(controller);
    };
    webView.onLoadError = (controller, url, code, message) {
      if (!completer.isCompleted) completer.completeError(message);
    };
    InAppWebViewController controller = await completer.future;
    return [controller, webView];
  }

  /// To print logs from this library
  /// set `enableLogs(true)`
  /// by default its false
  static enableLogs(bool enable) {
    WhatsappLogger.enableLogger = enable;
  }
}
