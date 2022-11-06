# Whatsapp bot flutter Mobile

![PicsArt_11-06-01 10 14](https://user-images.githubusercontent.com/59526499/200159656-aa778efd-7947-4c82-998f-2ae0804237a3.png)

[![whatsapp_bot_flutter_mobile version](https://img.shields.io/pub/v/whatsapp_bot_flutter?label=whatsapp_bot_flutter)](https://pub.dev/packages/whatsapp_bot_flutter_mobile)

Whatsapp bot using whatsapp web scraping

## Getting Started

This library is for Flutter Mobile (Android/Ios) platforms only ,using [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview)
To create a desktop or pure dart whatsapp bot , checkout my another library [whatsapp_bot_flutter](https://pub.dev/packages/whatsapp_bot_flutter)

### Android/IOS setup

To setup on Android , make sure to checkout `flutter_inappwebview` setup document for [Android](https://inappwebview.dev/docs/intro#setup-android) and [IOS](https://inappwebview.dev/docs/intro#setup-ios)
Android sdk:minSdkVersion cannot be smaller than version 19

## Usage

First we have to get `WhatsappClient` using `WhatsappBotFlutterMobile.connect` method , we can get qrcode from `onQrCode` callback, this will return a qrString and ImageByte , we can use ImageBytes to show qr as Image widget , or we can convert qrCode String to QrCode widget by any library,

```dart
WhatsappClient? whatsappClient = await WhatsappBotFlutterMobile.connect(
  onConnectionEvent: (ConnectionEvent event) {
    print(event.toString());
  },
  onQrCode: (String qr, Uint8List? imageBytes) {
    // use imageBytes to display in flutter : Image.memory(imageBytes)
  },
);
```

We have these modules to access whatsappClient features :

```dart
WhatsappClient.chat
WhatsappClient.contact
WhatsappClient.profile
```

Use `sendTextMessage` to send a text message

phone parameter can be of this format : `countryCode+phoneNumber` , eg : `91xxxxxxxxxx` , or we can get phone from messageEvents in this format : `countryCode+phone+"@c.us"`

```dart
await whatsappClient.chat.sendTextMessage(
    phone: "------",
    message: "Test Message",
);
```

Use `sendFileMessage` to send a File

```dart
await whatsappClient.chat.sendFileMessage(
    phone: "------",
    fileBytes: fileBytes, // Pass file bytes
    caption: "Test Message", // Optional
    fileType: fileType, // document, image, audio
);
```

To get new Messages , subscribe to `whatsappClient.messageEvents`

```dart
whatsappClient.messageEvents.listen((Message message) {
    // replyMessageId  is optional , add this to send a reply message
    whatsappClient.chat.sendTextMessage(
      phone: message.from,
      message: "Hey !",
      replyMessageId: message.id,
    );
});
```

To get whatsapp connection Events , subscribe to `whatsappClient.connectionEventStream`

```dart
whatsappClient.connectionEventStream.listen((event) {
  // Connection Events : authenticated,logout,connected.....
});
```

To get whatsapp calls Events , subscribe to `whatsappClient.callEvents`

```dart
whatsappClient.callEvents.listen((event) {
  // To reject call
  whatsappClient.rejectCall(callId: event.id);
});
```

## Features

Supported Whatsapp features :

- Create multiple whatsapp clients
- Login with QR
- Auto refresh QrCode
- Logout
- Keep session
- Listen to New Messages
- Listen to Connection Events
- Listen to calls
- Reject calls
- Send text message
- Send image, audio & document
- Send location message
- Send poll in groups
- Send contact card
- Reply to a message
- Archive/Unarchive chats
- Mute/Unmute chat
- Clear chat
- Delete chat
- Get lastSeen
- Get chats
- Mark messages as seen
- Mark message as unread
- Pin/Unpin chat
- Delete messages
- Download media
- Get messages
- Get profile picture
- Get status
- Get contacts
- Get status of loggedIn user
- Set status
- check if logged in user have business account
- Set profile picture of logged in user

## Resources

Thanks to [wa-js](https://github.com/wppconnect-team/wa-js) for exporting functions from WhatsApp Web

And [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) for Headless WebView

## Disclaimer

This project is not affiliated, associated, authorized, endorsed by, or in any way officially connected with WhatsApp or any of its subsidiaries or its affiliates. The official WhatsApp website can be found at https://whatsapp.com. "WhatsApp" as well as related names, marks, emblems and images are registered trademarks of their respective owners.

## Note

Its just initial version, I can't guarantee you will not be blocked by using this method, try to avoid primary whatsapp numbers. WhatsApp does not allow bots or unofficial clients on their platform, so this shouldn't be considered totally safe.
