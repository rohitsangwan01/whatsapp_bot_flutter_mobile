import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/qr_code_helper.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';
import 'package:whatsapp_bot_flutter_mobile/src/wpp/wpp_auth.dart';
import '../../whatsapp_bot_flutter_mobile.dart';
import '../model/qr_code_image.dart';

/// [waitForLogin] will either complete with successful login
/// or failed with timeout exception
/// this method will automatically try to get the qrCode
/// also it will make sure that we get the latest qrCode
Future waitForLogin(
  InAppWebViewController controller,
  Function(QrCodeImage, int)? onCatchQR, {
  int waitDurationSeconds = 60,
  Function(ConnectionEvent)? onConnectionEvent,
}) async {
  WhatsappLogger.log('Waiting page load');

  WhatsappLogger.log('Checking is logged...');
  WppAuth wppAuth = WppAuth(controller);

  bool authenticated = await wppAuth.isAuthenticated();

  if (!authenticated) {
    onConnectionEvent?.call(ConnectionEvent.waitingForQrScan);

    WhatsappLogger.log('Waiting for QRCode Scan...');

    await waitForQrCodeScan(
      controller: controller,
      onCatchQR: onCatchQR,
      waitDurationSeconds: waitDurationSeconds,
    );

    WhatsappLogger.log('Checking QRCode status...');

    await Future.delayed(const Duration(milliseconds: 200));

    authenticated = await wppAuth.isAuthenticated();

    if (authenticated) {
      onConnectionEvent?.call(ConnectionEvent.authenticated);

      await Future.delayed(const Duration(milliseconds: 200));
      WhatsappLogger.log('Checking phone is connected...');

      onConnectionEvent?.call(ConnectionEvent.connecting);
      bool inChat = await _waitForInChat(controller);
      if (!inChat) {
        WhatsappLogger.log('Phone not connected');
        throw 'Phone not connected';
      }

      WhatsappLogger.log('Connected successfully');
      onConnectionEvent?.call(ConnectionEvent.connected);
    } else {
      throw 'Login Failed';
    }
  } else {
    await Future.delayed(const Duration(milliseconds: 200));
    WhatsappLogger.log('Checking phone is connected...');

    onConnectionEvent?.call(ConnectionEvent.connecting);
    bool inChat = await _waitForInChat(controller);
    if (!inChat) {
      WhatsappLogger.log('Phone not connected');
      throw 'Phone not connected';
    }
    WhatsappLogger.log('Connected successfully');
    onConnectionEvent?.call(ConnectionEvent.connected);
  }
}

Future<bool> _waitForInChat(InAppWebViewController controller) async {
  var inChat = await WppAuth(controller).isMainReady();
  if (inChat) return true;
  Completer<bool> completer = Completer();
  late Timer timer;
  WppAuth wppAuth = WppAuth(controller);
  timer = Timer.periodic(const Duration(milliseconds: 1000), (tim) async {
    if (tim.tick > 60) {
      timer.cancel();
      if (!completer.isCompleted) completer.complete(false);
    } else {
      bool inChat = await wppAuth.isMainReady();
      if (inChat && !completer.isCompleted) {
        timer.cancel();
        completer.complete(true);
      }
    }
  });
  return completer.future;
}
