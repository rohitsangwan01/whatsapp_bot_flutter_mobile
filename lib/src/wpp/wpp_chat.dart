import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';

import '../../whatsapp_bot_flutter_mobile.dart';

class WppChat {
  InAppWebViewController controller;
  WppChat(this.controller);

  /// [sendMessage] may throw errors if passed an invalid contact
  /// or if this method completed without any issue , then probably message sent successfully
  /// add `replyMessageId` to quote message
  Future sendTextMessage({
    required String phone,
    required String message,
    MessageId? replyMessageId,
  }) async {
    String? replyText = replyMessageId?.serialized;
    if (replyText != null) {
      return await _executeMethod(
          '''WPP.chat.sendTextMessage('${parsePhone(phone)}', '$message', {
            quotedMsg: "$replyText"
          });''',
          methodName: "sendTextMessage");
    } else {
      return await _executeMethod(
          '''WPP.chat.sendTextMessage('${parsePhone(phone)}', '$message');''',
          methodName: "sendTextMessage");
    }
  }

  ///send file messages using [sendFileMessage]
  /// make sure to send fileType , we can also pass optional mimeType
  /// `replyMessageId` will send a quote message to the given messageId
  /// add `caption` to attach a text with the file
  Future sendFileMessage({
    required String phone,
    required WhatsappFileType fileType,
    required List<int> fileBytes,
    String? caption,
    String? mimetype,
    MessageId? replyMessageId,
  }) async {
    await validateConnection(controller);
    String phoneNum = parsePhone(phone);

    String base64Image = base64Encode(fileBytes);
    String mimeType = mimetype ?? getMimeType(fileType);
    String fileData = "data:$mimeType;base64,$base64Image";
    String fileTypeName = "image";
    if (mimeType.split("/").length > 1) {
      fileTypeName = mimeType.split("/").first;
    }
    String? replyTextId = replyMessageId?.serialized;
    String source = '''WPP.chat.sendFileMessage("$phoneNum","$fileData",{
                          type: "$fileTypeName",
                      });''';
    if (caption != null && replyTextId != null) {
      source = '''WPP.chat.sendFileMessage("$phoneNum","$fileData",{
                    type: "$fileTypeName",
                    caption: "$caption",
                    quotedMsg: "$replyTextId"
                  });''';
    } else if (caption != null) {
      source = '''WPP.chat.sendFileMessage("$phoneNum","$fileData",{
                    type: "$fileTypeName",
                    caption: "$caption",
                  });''';
    } else if (replyTextId != null) {
      source = '''WPP.chat.sendFileMessage("$phoneNum","$fileData",{
                    type: "$fileTypeName",
                    quotedMsg: "$replyTextId"
                  });''';
    }
    var sendResult = await controller.evaluateJavascript(
      source: source,
    );
    WhatsappLogger.log("SendResult : $sendResult");
    return sendResult;
  }

  Future sendContactCard({
    required String phone,
    required String contactPhone,
    required String contactName,
  }) async {
    return await _executeMethod(
        '''WPP.chat.sendVCardContactMessage("${parsePhone(phone)}", {
            id: "${parsePhone(contactPhone)}",
            name: "$contactName"
          });''',
        methodName: "sendContactCard");
  }

  ///send a locationMessage using [sendLocationMessage]
  Future sendLocationMessage({
    required String phone,
    required String lat,
    required String long,
    String? name,
    String? address,
    String? url,
  }) async {
    return await _executeMethod(
        '''WPP.chat.sendLocationMessage("${parsePhone(phone)}", {
              lat: "$lat",
              lng: "$long",
              name: "$name", 
              address: "$address",
              url: "$url" 
            });
            ''',
        methodName: "sendLocationMessage");
  }

  ///Pass phone with correct format in [archive] , and
  ///archive = true to archive , and false to unarchive
  Future<void> archive({required String phone, bool archive = true}) async {
    return await _executeMethod(
      '''WPP.chat.archive("${parsePhone(phone)}", $archive);''',
      methodName: "Archive",
    );
  }

  /// check if the given Phone number is a valid phone number
  Future<bool> isValidContact(String phone) async {
    return await _executeMethod(
      '''WPP.contact.queryExists("${parsePhone(phone)}");''',
      methodName: "isValidContact",
    );
  }

  /// to check if we [canMute] phone number
  Future<bool> canMute(phone) async =>
      await _executeMethod('''WPP.chat.canMute("${parsePhone(phone)}");''',
          methodName: "CanMute");

  ///Mute a chat, you can use  expiration and use unix timestamp (seconds only)
  Future mute({
    required String phone,
    required int expirationUnixTimeStamp,
  }) async {
    if (!await canMute(phone)) throw "Cannot Mute $phone";
    return await _executeMethod(
        '''WPP.chat.mute("${parsePhone(phone)}",{expiration: $expirationUnixTimeStamp});''',
        methodName: "Mute");
  }

  /// Un mute chat
  Future unmute({required String phone}) async {
    return await _executeMethod(
        '''=>WPP.chat.unmute("${parsePhone(phone)}");''',
        methodName: "unmute");
  }

  /// [clear] chat
  Future clear({
    required String phone,
    bool keepStarred = false,
  }) async =>
      await _executeMethod(
          '''WPP.chat.clear("${parsePhone(phone)}",$keepStarred);''',
          methodName: "ClearChat");

  /// [delete] chat
  Future delete({
    required String phone,
  }) async =>
      await _executeMethod('''WPP.chat.delete("${parsePhone(phone)}");''',
          methodName: "DeleteChat");

  ///Get timestamp of last seen using [getLastSeen]
  /// return either a timestamp or 0 if last seen off
  Future<int> getLastSeen({required String phone}) async {
    var lastSeen = await _executeMethod(
        '''WPP.chat.getLastSeen("${parsePhone(phone)}");''',
        methodName: "GetLastSeen");
    if (lastSeen.runtimeType == bool) return lastSeen ? 1 : 0;
    return lastSeen;
  }

  /// get all Chats using [getChats]
  Future getChats({bool? onlyUser, bool? onlyGroups}) async {
    if (onlyUser == true) {
      return await _executeMethod('''WPP.chat.list({onlyUsers: true});''',
          methodName: "GetChats");
    } else if (onlyGroups == true) {
      return await _executeMethod('''WPP.chat.list({onlyGroups: true});''',
          methodName: "GetChats");
    } else {
      return await _executeMethod('''WPP.chat.list();''',
          methodName: "GetChats");
    }
  }

  ///Mark a chat as read and send SEEN event
  Future markAsSeen({required String phone}) async {
    return await _executeMethod(
        '''WPP.chat.markIsRead("${parsePhone(phone)}");''',
        methodName: "MarkIsRead");
  }

  ///Mark a chat as unread
  Future markAsUnread({required String phone}) async {
    return await _executeMethod(
        '''WPP.chat.markIsUnread("${parsePhone(phone)}");''',
        methodName: "MarkIsUnread");
  }

  ///pin/unpin to chat
  Future pin({required String phone, bool pin = true}) async {
    return await _executeMethod(
        '''WPP.chat.pin("${parsePhone(phone)}",$pin);''',
        methodName: "pin");
  }

  /// Delete messages
  Future deleteMessages({
    required String phone,
    required List<String> messageIds,
  }) async {
    return await _executeMethod(
        '''WPP.chat.deleteMessage("${parsePhone(phone)}",$messageIds);''',
        methodName: "deleteMessages");
  }

  /// Download the blob of a media message
  Future downloadMedia({required String mediaMessageId}) async {
    return await _executeMethod(
        '''WPP.chat.downloadMedia("$mediaMessageId");''',
        methodName: "downloadMedia");
  }

  /// Fetch messages from a chat
  Future getMessages({required String phone, int count = -1}) async {
    return await _executeMethod(
        '''WPP.chat.getMessages("${parsePhone(phone)}",{count: $count,});''',
        methodName: "getMessages");
  }

  /// Send a create poll message , Note: This only works for groups
  Future sendCreatePollMessage(
      {required String phone,
      required String pollName,
      required List<String> pollOptions}) async {
    return await _executeMethod(
        '''WPP.chat.sendCreatePollMessage("${parsePhone(phone)}","$pollName",$pollOptions);''',
        methodName: "sendCreatePollMessage");
  }

// common method to execute a task
  Future _executeMethod(
    String method, {
    String methodName = "",
  }) async {
    await validateConnection(controller);
    var result = await controller.evaluateJavascript(source: method);
    WhatsappLogger.log("${methodName}Result : $result");
    return result;
  }
}
