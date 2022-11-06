import 'dart:async';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';
import 'package:whatsapp_bot_flutter_mobile/src/model/call_event.dart';
import 'package:whatsapp_bot_flutter_mobile/src/model/connection_event.dart';
import 'package:whatsapp_bot_flutter_mobile/src/model/message.dart';

class WppEvents {
  InAppWebViewController controller;
  WppEvents(this.controller);

  // To get update of all messages
  final StreamController<Message> messageEventStreamController =
      StreamController.broadcast();

  // To get update of all Calls
  final StreamController<CallEvent> callEventStreamController =
      StreamController.broadcast();

  // To get update of all Connections
  final StreamController<ConnectionEvent> connectionEventStreamController =
      StreamController.broadcast();

  /// call init() once on a page
  /// to add eventListeners
  Future<void> init() async {
    await _addEventListeners();
  }

  Future<void> _addEventListeners() async {
    try {
      // Add Dart side method
      await _exposeListener();

      // Add all listeners
      await controller.evaluateJavascript(
        source: '''function initEvents() {
            WPP.on('chat.new_message', (msg) => {
              window.flutter_inappwebview.callHandler('onCustomEvent', {type:"messageEvent",data:msg});
            });
            WPP.on('call.incoming_call', (call) => {
              window.flutter_inappwebview.callHandler('onCustomEvent', {type:"callEvent",data:call});
            });
            WPP.on('conn.authenticated', () => {
               window.flutter_inappwebview.callHandler('onCustomEvent', {type:"connectionEvent",data:"authenticated"});
            });
             WPP.on('conn.logout', () => {
              window.flutter_inappwebview.callHandler('onCustomEvent', {type:"connectionEvent",data:"authenticated"});
              window.onCustomEvent("connectionEvent","logout");
            });
            WPP.on('conn.auth_code_change', () => {
              window.flutter_inappwebview.callHandler('onCustomEvent', {type:"connectionEvent",data:"auth_code_change"});
            });
            WPP.on('conn.main_loaded', () => {
              window.flutter_inappwebview.callHandler('onCustomEvent', {type:"connectionEvent",data:"main_loaded"});
            });
            WPP.on('conn.main_ready', () => {
              window.flutter_inappwebview.callHandler('onCustomEvent', {type:"connectionEvent",data:"main_ready"});
            });
            WPP.on('conn.require_auth', () => {
              window.flutter_inappwebview.callHandler('onCustomEvent', {type:"connectionEvent",data:"require_auth"});
            });
        }
        initEvents();
        ''',
      );
    } catch (e) {
      // Ignore for now
      WhatsappLogger.log(e);
    }
  }

  void _onNewMessage(msg) {
    try {
      Message message = Message.fromJson(msg);
      messageEventStreamController.add(message);
    } catch (e) {
      WhatsappLogger.log("onMessageError : $e");
    }
  }

  void _onCallEvent(call) {
    try {
      CallEvent callEvent = CallEvent.fromJson(call);
      callEventStreamController.add(callEvent);
    } catch (e) {
      WhatsappLogger.log("onCallEvent : $e");
    }
  }

  void _onConnectionEvent(event) {
    ConnectionEvent? connectionEvent;
    switch (event) {
      case "authenticated":
        connectionEvent = ConnectionEvent.authenticated;
        break;
      case "logout":
        connectionEvent = ConnectionEvent.logout;
        break;
      case "auth_code_change":
        connectionEvent = ConnectionEvent.authCodeChange;
        break;
      case "main_loaded":
        connectionEvent = ConnectionEvent.connecting;
        break;
      case "main_ready":
        connectionEvent = ConnectionEvent.connected;
        break;
      case "require_auth":
        connectionEvent = ConnectionEvent.requireAuth;
        break;
      default:
        WhatsappLogger.log("Unknown Event : $event");
    }
    if (connectionEvent == null) return;
    connectionEventStreamController.add(connectionEvent);
  }

  Future<void> _exposeListener() async {
    controller.addJavaScriptHandler(
        handlerName: "onCustomEvent",
        callback: (arguments) {
          // WhatsappLogger.log(arguments);
          var type = arguments[0]["type"];
          var data = arguments[0]["data"];
          switch (type.toString()) {
            case "messageEvent":
              _onNewMessage(data);
              break;
            case "connectionEvent":
              _onConnectionEvent(data);
              break;
            case "callEvent":
              _onCallEvent(data);
          }
        });
  }
}
