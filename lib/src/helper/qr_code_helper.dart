// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';
import 'package:whatsapp_bot_flutter_mobile/src/model/qr_code_image.dart';
import 'package:whatsapp_bot_flutter_mobile/src/wpp/wpp_auth.dart';

///[qrCodeImage] will give us a Stream of QrCode
/// call init method with page
Future<void> waitForQrCodeScan({
  required InAppWebViewController controller,
  int waitDurationSeconds = 60,
  Function(QrCodeImage, int)? onCatchQR,
}) async {
  String? urlCode;
  int attempt = 0;
  Completer completer = Completer();
  bool closeLoop = false;

  Timer timer = Timer(Duration(seconds: waitDurationSeconds), () async {
    if (!completer.isCompleted) completer.complete();
    closeLoop = true;
  });

  while (true) {
    if (closeLoop) break;
    bool connected = await WppAuth(controller).isAuthenticated();
    if (connected) {
      timer.cancel();
      if (!completer.isCompleted) completer.complete();
      break;
    }

    QrCodeImage? result = await _getQrCodeImage(controller);
    String? code = result?.urlCode;

    if (result != null && code != null && code != urlCode) {
      urlCode = code;
      attempt++;
      WhatsappLogger.log('Waiting for QRCode Scan: Attempt $attempt');
      onCatchQR?.call(result, attempt);
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  await completer.future;
}

Future<QrCodeImage?> _getQrCodeImage(InAppWebViewController controller) async {
  try {
    var result = await controller.evaluateJavascript(source: '''
      function getQr()  {
            const selectorImg = document.querySelector('canvas');
            const selectorUrl = selectorImg.closest('[data-ref]');
            if (selectorImg != null && selectorUrl != null) {
              let data = {
                base64Image: selectorImg.toDataURL(),
                urlCode: selectorUrl.getAttribute('data-ref'),
              };
              return data;
            }
          }
          getQr();
    ''');
    String? urlCode = result?['urlCode'];
    String? base64Image = result?['base64Image'];
    return QrCodeImage(base64Image: base64Image, urlCode: urlCode);
  } catch (e) {
    WhatsappLogger.log("QrCodeFetchingError: $e");
    return null;
  }
}
