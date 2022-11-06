import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_bot_flutter_mobile/src/helper/utils.dart';

class WppProfile {
  InAppWebViewController controller;
  WppProfile(this.controller);

  /// Get your current text status
  Future getMyStatus() async {
    return await _executeMethod('''() =>WPP.profile.getMyStatus();''',
        methodName: "getMyStatus");
  }

  /// Update your current text status
  Future setMyStatus({required String status}) async {
    return await _executeMethod('''WPP.profile.setMyStatus("$status");''',
        methodName: "setMyStatus");
  }

  /// Update your profile picture
  Future setMyProfilePicture({
    required List<int> imageBytes,
  }) async {
    String base64Image = base64Encode(imageBytes);
    String imageData = 'data:image/jpeg;base64,$base64Image';
    return await _executeMethod(
        '''WPP.profile.setMyProfilePicture("$imageData");''',
        methodName: "getMyStatus");
  }

  /// Return the current logged user is Business or not
  Future<bool> isBusiness() async {
    return await _executeMethod('''WPP.profile.isBusiness();''',
        methodName: "isBusiness");
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
