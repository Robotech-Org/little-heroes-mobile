import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:little_heroes_mobile/core/constants/app_colors.dart';

class ChapaWebViewPage extends StatefulWidget {
  final String checkoutUrl;
  final String invoiceName;
  final String? returnUrlPattern;

  const ChapaWebViewPage({
    super.key,
    required this.checkoutUrl,
    required this.invoiceName,
    this.returnUrlPattern,
  });

  @override
  State<ChapaWebViewPage> createState() => _ChapaWebViewPageState();
}

class _ChapaWebViewPageState extends State<ChapaWebViewPage> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _hasFinished = false;

  static const _successPaths = [
    '/payment/success',
    '/payment/callback',
    '/payment/verify',
  ];
  static const _cancelPaths = ['/payment/cancel', '/payment/failed'];

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p / 100);
          },
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();

            final matchesPattern =
                widget.returnUrlPattern != null &&
                url.contains(widget.returnUrlPattern!.toLowerCase());
            final matchesSuccess = _successPaths.any((p) => url.contains(p));
            final matchesCancel = _cancelPaths.any((p) => url.contains(p));

            if (matchesPattern || matchesSuccess || matchesCancel) {
              _finish(url);
              return NavigationDecision.prevent;
            }

            if (url.startsWith('littleheroes://') ||
                url.startsWith('intent://')) {
              _finish(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _isSuccess(String url) =>
      !url.contains('cancel') && !url.contains('failed');

  void _finish(String url) {
    if (_hasFinished) return;
    _hasFinished = true;
    if (mounted) Navigator.of(context).pop(_isSuccess(url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cancel payment?'),
            content: const Text(
              'If you leave now, your payment may still be processing.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Leave'),
              ),
            ],
          ),
        );
        if (leave == true && mounted) Navigator.pop(context, false);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Complete Payment',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          foregroundColor: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: Column(
          children: [
            if (_progress < 1.0)
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                minHeight: 3,
                backgroundColor: Colors.transparent,
                color: colorScheme.primary,
              ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
