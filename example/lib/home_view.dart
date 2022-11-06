import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Form(
        key: controller.formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const ConnectDisconnectWidget(),

              // Show Error
              Obx(() {
                return controller.error.value.isEmpty
                    ? const SizedBox()
                    : Text(
                        controller.error.value,
                        style: const TextStyle(color: Colors.red),
                      );
              }),

              const MiddleFormView(),
              // Mid Widget
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () => controller.sendMessage(),
                        child: const Text("Send Text")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () => controller.sendImage(),
                        child: const Text("Send Image")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () => controller.sendAudio(),
                        child: const Text("Send Audio")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () => controller.sendDocument(),
                        child: const Text("Send Document")),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Divider(),
              ),

              // Bottom Widgets
              Obx(() => Text(
                    "ConnectionEvent : ${controller.connectionEvent.value?.name}",
                  )),
              const Divider(),
              Obx(() => Text(
                    "Messages : ${controller.messageEvents.value?.body}",
                  )),
              const Divider(),
              Obx(() => Text(
                    "Calls : ${controller.callEvents.value?.sender}",
                  )),
            ],
          ),
        ),
      ),
    ));
  }
}

class MiddleFormView extends GetView<HomeController> {
  const MiddleFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller.phoneNumber,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return "Enter phone number with country code";
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: "Phone number with country code",
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller.message,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return "Please type a message";
            }
            if (!controller.connected.value) {
              return "Please connect with Whatsapp first";
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: "Message text",
          ),
        ),
      ),
    ]);
  }
}

class ConnectDisconnectWidget extends GetView<HomeController> {
  const ConnectDisconnectWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => controller.initConnection(),
              child: const Text("Connect Headless"),
            ),
            const SizedBox(width: 10),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.webViewController.value == null
                    ? null
                    : () => controller.connectUsingWebView(),
                child: const Text("Connect using WebView"),
              );
            }),
          ],
        ),
        Row(
          children: [
            Obx(() => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.circle,
                    color:
                        controller.connected.value ? Colors.green : Colors.red,
                  ),
                )),
            ElevatedButton(
              onPressed: () => controller.disconnect(),
              child: const Text("Disconnect"),
            ),
          ],
        )
      ],
    );
  }
}
