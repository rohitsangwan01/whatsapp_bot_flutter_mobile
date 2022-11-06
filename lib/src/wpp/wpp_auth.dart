import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';

class WppAuth {
  InAppWebViewController controller;
  WppAuth(this.controller);

  /// check if User is Authenticated on current opened Page
  Future<bool> isAuthenticated() async {
    try {
      var result = await controller
          .evaluateJavascript(source: '''WPP.conn.isAuthenticated();''');
      return result;
    } catch (e) {
      WhatsappLogger.log(e.toString());
      return false;
    }
  }

  /// to check if ChatScreen is loaded on the page
  Future<bool> isMainReady() async {
    try {
      var result = await controller
          .evaluateJavascript(source: '''WPP.conn.isMainReady();''');
      return result;
    } catch (e) {
      WhatsappLogger.log(e.toString());
      return false;
    }
  }

  /// To Logout
  Future logout() async {
    try {
      await controller.evaluateJavascript(source: '''WPP.conn.logout();''');
    } catch (e) {
      throw "Logout Failed";
    }
  }
}
