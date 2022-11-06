// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:whatsapp_bot_example/home_view.dart';
import 'package:whatsapp_bot_example/inapp_webview.dart';

// TO contain tabBar with persistent State
class MainPersistentTabBar extends StatelessWidget {
  const MainPersistentTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "Home"),
              Tab(text: "WebView"),
            ],
          ),
          title: const Text('Whatsapp Bot'),
        ),
        body: const TabBarView(
          children: [
            PersistentStateWidget(child: HomeView()),
            PersistentStateWidget(child: InAppWebViewPage()),
          ],
        ),
      ),
    );
  }
}

class PersistentStateWidget extends StatefulWidget {
  final Widget child;
  const PersistentStateWidget({Key? key, required this.child})
      : super(key: key);

  @override
  State<PersistentStateWidget> createState() => _PersistentStateWidgetState();
}

class _PersistentStateWidgetState extends State<PersistentStateWidget>
    with AutomaticKeepAliveClientMixin<PersistentStateWidget> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
