import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../helper/utils.dart';

class WppContact {
  InAppWebViewController controller;
  WppContact(this.controller);

  /// get ProfilePictureUrl of any Number
  Future getProfilePictureUrl({
    required String phone,
  }) async {
    return await _executeMethod(
      '''WPP.contact.getProfilePictureUrl("${parsePhone(phone)}");''',
    );
  }

  /// Get the current text status of contact
  Future getStatus({
    required String phone,
  }) async {
    return await _executeMethod(
      '''WPP.contact.getStatus("${parsePhone(phone)}");''',
    );
  }

  /// Return to list of contacts
  Future getContacts() async {
    return await _executeMethod('''WPP.contact.list();''',
        methodName: "getContacts");
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
