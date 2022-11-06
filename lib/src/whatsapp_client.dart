import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';
import 'package:whatsapp_bot_flutter_mobile/src/wpp/wpp_chat.dart';
import 'package:whatsapp_bot_flutter_mobile/src/wpp/wpp_contact.dart';
import 'package:whatsapp_bot_flutter_mobile/src/wpp/wpp_events.dart';
import 'package:whatsapp_bot_flutter_mobile/src/wpp/wpp_auth.dart';
import 'package:whatsapp_bot_flutter_mobile/src/wpp/wpp_profile.dart';
import 'package:whatsapp_bot_flutter_mobile/whatsapp_bot_flutter_mobile.dart';

/// get [WhatsappClient] from `WhatsappBotFlutter.connect()`
/// please do not try to create on your own
class WhatsappClient {
  InAppWebViewController controller;
  HeadlessInAppWebView? headlessInAppWebView;
  late WppEvents _wppEvents;
  late WppAuth _wppAuth;
  late WppChat chat;
  // To access all contact features
  late WppContact contact;
  // To access all profile features
  late WppProfile profile;

  WhatsappClient({
    required this.controller,
    this.headlessInAppWebView,
  }) {
    chat = WppChat(controller);
    contact = WppContact(controller);
    profile = WppProfile(controller);
    _wppAuth = WppAuth(controller);
    _wppEvents = WppEvents(controller);
    _wppEvents.init().then((value) {
      WhatsappLogger.log("_wppEvents initialized");
    });
  }

  /// [isAuthenticated] is to check if we are loggedIn
  Future<bool> get isAuthenticated => _wppAuth.isAuthenticated();

  /// [isReadyToChat] is to check if whatsapp chat Page opened
  Future<bool> get isReadyToChat => _wppAuth.isMainReady();

  /// [connectionEventStream] will give update of Connection Events
  Stream<ConnectionEvent> get connectionEventStream =>
      _wppEvents.connectionEventStreamController.stream;

  ///[messageEvents] will give update of all new messages
  Stream<Message> get messageEvents =>
      _wppEvents.messageEventStreamController.stream;

  ///[callEvents] will give update of all calls
  Stream<CallEvent> get callEvents =>
      _wppEvents.callEventStreamController.stream;

  /// [disconnect] will close the browser instance and set values to null
  Future<void> disconnect({
    bool tryLogout = false,
  }) async {
    try {
      if (tryLogout) await logout();
      await headlessInAppWebView?.dispose();
    } catch (e) {
      WhatsappLogger.log(e);
    }
  }

  ///[logout] will try to logout only if We are connected and already logged in
  Future<void> logout() async {
    try {
      await _wppAuth.logout();
    } catch (e) {
      WhatsappLogger.log(e);
    }
  }

  /// [rejectCall] will reject incoming call
  Future<void> rejectCall({String? callId}) async {
    var result = await controller.evaluateJavascript(
      source: '''WPP.call.rejectCall("$callId");''',
    );
    WhatsappLogger.log("RejectCallResult : $result");
  }
}
