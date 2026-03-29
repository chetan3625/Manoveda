import 'package:flutter/material.dart';
import 'package:manoveda/widgets/app_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          "https://app.thinkstack.ai/bot/index.html?chatbot_id=68b5b47cf2e2974d6a9aa96b",
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
