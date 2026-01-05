import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final User user;
  final String petId;
  final String amount;

  const PaymentPage({
    super.key,
    required this.user,
    required this.petId,
    required this.amount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPage();
}

class _PaymentPage extends State<PaymentPage> {
  late WebViewController _webController;
  @override
  void initState() {
    super.initState();

    String url =
        "${MyConfig.baseUrl}/pawpal/server/api/submit_donation.php?"
        "userid=${widget.user.userId}&"
        "email=${widget.user.userEmail}&"
        "phone=${widget.user.userPhone}&"
        "name=${widget.user.userName}&"
        "petid=${widget.petId}&"
        "amount=${widget.amount}";

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains("pawpal://return")) {
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.orange,
      ),
      body: WebViewWidget(controller: _webController),
    );
  }
}
