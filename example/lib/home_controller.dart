// ignore_for_file: unnecessary_overrides

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:whatsapp_bot_flutter_mobile/whatsapp_bot_flutter_mobile.dart';

class HomeController extends GetxController {
  RxString error = "".obs;
  RxInt progress = 0.obs;
  RxBool connected = false.obs;
  Rx<InAppWebViewController?> webViewController = Rxn<InAppWebViewController>();

  var message = TextEditingController();
  var phoneNumber = TextEditingController();

  var formKey = GlobalKey<FormState>();

  /// reactive variables from Getx
  Rx<ConnectionEvent?> connectionEvent = Rxn<ConnectionEvent>();
  Rx<Message?> messageEvents = Rxn<Message>();
  Rx<CallEvent?> callEvents = Rxn<CallEvent>();

  // Native chrome client supported only on desktop platforms
  bool supportNativeChromeClient = !GetPlatform.isWeb && GetPlatform.isDesktop;

  WhatsappClient? client;

  @override
  void onInit() {
    WhatsappBotFlutterMobile.enableLogs(true);
    phoneNumber.text = "";
    message.text = "Testing Whatsapp Bot";
    super.onInit();
  }

  void connectUsingWebView() {
    if (webViewController.value == null) {
      error.value = "WebViewNotReady yet";
      return;
    }
    initConnection(controller: webViewController.value);
  }

  void initConnection({InAppWebViewController? controller}) async {
    error.value = "";
    connected.value = false;
    try {
      client = await WhatsappBotFlutterMobile.connect(
        inAppWebViewController: controller,
        onConnectionEvent: (ConnectionEvent event) {
          connectionEvent(event);
          if (event == ConnectionEvent.connected) {
            _closeQrCodeDialog();
          }
        },
        onQrCode: (String qr, Uint8List? imageBytes) {
          _closeQrCodeDialog();
          _showQrCodeDialog(qr);
        },
      );
      connected.value = true;
      if (client != null) initStreams(client!);
    } catch (er) {
      error.value = er.toString();
    }
  }

  void _closeQrCodeDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  void _showQrCodeDialog(String qrString) {
    Get.defaultDialog(
      title: "Scan QrCode",
      content: PrettyQr(
        size: 300,
        data: qrString,
        roundEdges: true,
      ),
      onCancel: () {},
    );
  }

  void initStreams(WhatsappClient client) async {
    // listen to ConnectionEvent Stream
    client.connectionEventStream.listen((event) {
      connectionEvent.value = event;
    });
    // listen to CallEvent Stream
    client.callEvents.listen((event) {
      callEvents.value = event;
      client.rejectCall(callId: event.id);
      client.chat.sendTextMessage(
        phone: event.sender,
        message: "Hey, Call rejected by whatsapp bot",
      );
    });
    // listen to messageEventStream
    client.messageEvents.listen((Message message) {
      if (!(message.id?.fromMe ?? true)) {
        Get.log(message.toJson().toString());
        messageEvents.value = message;
        // auto reply if message == test
        if (message.body == "test") {
          client.chat.sendTextMessage(
            phone: message.from,
            message: "Hey !",
            replyMessageId: message.id,
          );
        }
      }
    });
  }

  void disconnect() async {
    await client?.disconnect(tryLogout: true);
    connected.value = false;
  }

  void sendMessage() async {
    if (!formKey.currentState!.validate()) return;
    try {
      await client?.chat.sendTextMessage(
        phone: phoneNumber.text,
        message: message.text,
      );
    } catch (e) {
      Get.log("Error : $e");
    }
  }

  Future<void> sendFileMessage(
    String? filePath,
    WhatsappFileType fileType,
  ) async {
    if (!formKey.currentState!.validate()) return;
    try {
      if (filePath == null) return;
      File file = File(filePath);
      List<int> imageBytes = file.readAsBytesSync();

      await client?.chat.sendFileMessage(
        phone: phoneNumber.text,
        fileBytes: imageBytes,
        caption: message.text,
        fileType: fileType,
      );
    } catch (e) {
      Get.log("Error : $e");
    }
  }

  void sendImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    String? path = result?.files.first.path;
    await sendFileMessage(path, WhatsappFileType.image);
  }

  void sendDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    String? path = result?.files.first.path;
    await sendFileMessage(path, WhatsappFileType.document);
  }

  void sendAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    String? path = result?.files.first.path;
    await sendFileMessage(path, WhatsappFileType.audio);
  }
}
