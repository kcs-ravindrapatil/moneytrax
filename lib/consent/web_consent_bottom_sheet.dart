import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens the official Sammati Web Notice SDK inside a Flutter bottom sheet.
Future<WebConsentResult?> showWebConsentDialog(
  BuildContext context, {
  required String apiBaseUrl,
  required String applicationKey,
  required String noticeCode,
  String? email,
  String? mobile,
  String? fullName,
}) {
  return showDialog<WebConsentResult>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    useSafeArea: false,
    builder: (dialogContext) {
      return Material(
        color: Colors.white,
        child: SizedBox.expand(
          child: _WebConsentView(
            apiBaseUrl: apiBaseUrl,
            applicationKey: applicationKey,
            noticeCode: noticeCode,
            email: email,
            mobile: mobile,
            fullName: fullName,
            onResult: (result) {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(result);
              }
            },
          ),
        ),
      );
    },
  );
}

final class WebConsentResult {
  const WebConsentResult({
    required this.ok,
    required this.cancelled,
    required this.allMandatoryGranted,
    this.linkRequired = false,
    this.artifactId,
    this.preferenceToken,
    this.message,
  });

  final bool ok;
  final bool cancelled;
  final bool allMandatoryGranted;
  final bool linkRequired;
  final String? artifactId;
  final String? preferenceToken;
  final String? message;

  factory WebConsentResult.fromJson(Map<String, dynamic> json) {
    return WebConsentResult(
      ok: json['ok'] == true,
      cancelled: json['cancelled'] == true,
      allMandatoryGranted: json['allMandatoryGranted'] == true,
      linkRequired: json['linkRequired'] == true,
      artifactId: json['artifactId']?.toString(),
      preferenceToken: json['preferenceToken']?.toString(),
      message: json['message']?.toString(),
    );
  }

  @override
  String toString() {
    return 'WebConsentResult('
        'ok: $ok, '
        'cancelled: $cancelled, '
        'allMandatoryGranted: $allMandatoryGranted, '
        'linkRequired: $linkRequired, '
        'artifactId: $artifactId, '
        'preferenceToken: $preferenceToken, '
        'message: $message'
        ')';
  }
}

class _WebConsentView extends StatefulWidget {
  const _WebConsentView({
    required this.apiBaseUrl,
    required this.applicationKey,
    required this.noticeCode,
    required this.onResult,
    this.email,
    this.mobile,
    this.fullName,
  });

  final String apiBaseUrl;
  final String applicationKey;
  final String noticeCode;

  final String? email;
  final String? mobile;
  final String? fullName;

  final ValueChanged<WebConsentResult> onResult;

  @override
  State<_WebConsentView> createState() => _WebConsentViewState();
}

class _WebConsentViewState extends State<_WebConsentView> {
  late final WebViewController _controller;
  bool _started = false;
  bool _resultReceived = false;

  static const String _html = r'''
    
    <!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
  >

  <style>
    html,
    body {
      margin: 0;
      padding: 0;
      width: 100%;
      min-height: 80%;
      background: transparent;
      overflow: auto;
      -webkit-overflow-scrolling: touch;
    }

    body {
      position: relative;
      min-height: 80vh;
    }
  </style>
</head>

<body>
  <script>
    window.startConsentFromFlutter = function(jsonString) {
      bootAndCapture(JSON.parse(jsonString));
    };

    async function bootAndCapture(config) {
      try {
        var script = document.createElement('script');

        script.src =
            String(config.apiBase).replace(/\/$/, '') +
            '/sdk/sammati-notice.min.js';

        script.setAttribute(
          'data-client-id',
          config.clientId,
        );

        script.setAttribute(
          'data-api-base',
          config.apiBase,
        );

        await new Promise(function(resolve, reject) {
          script.onload = resolve;

          script.onerror = function() {
            reject(
              new Error('SDK script failed to load'),
            );
          };

          document.head.appendChild(script);
        });

        var tries = 0;

        while (!window.SammatiNotice && tries < 40) {
          await new Promise(function(resolve) {
            setTimeout(resolve, 50);
          });

          tries++;
        }

        if (!window.SammatiNotice) {
          throw new Error('SammatiNotice not available');
        }

        var consent =
            await window.SammatiNotice.captureConsent({
          noticeCode: config.noticeCode,
          email: config.email || undefined,
          mobile: config.mobile || undefined,
          fullName: config.fullName || undefined,
        });

        ConsentBridge.postMessage(
          JSON.stringify({
            ok: true,
            cancelled: !!(
              consent &&
              consent.cancelled
            ),
            allMandatoryGranted: !!(
              consent &&
              consent.allMandatoryGranted
            ),
            linkRequired: !!(
              consent &&
              consent.linkRequired
            ),
            artifactId:
                consent && consent.artifactId
                    ? consent.artifactId
                    : null,
            preferenceToken:
                consent && consent.preferenceToken
                    ? consent.preferenceToken
                    : null,
          }),
        );
      } catch (e) {
        ConsentBridge.postMessage(
          JSON.stringify({
            ok: false,
            cancelled: false,
            allMandatoryGranted: false,
            linkRequired: false,
            artifactId: null,
            preferenceToken: null,
            message: String(
              e && e.message
                  ? e.message
                  : e,
            ),
          }),
        );
      }
    }
  </script>
</body>
</html>

    
    ''';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      /*
           * SDK requires JavaScript.
           */
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      /*
           * Transparent WebView background.
           */
      ..setBackgroundColor(Colors.transparent)
      /*
           * Flutter <-> JavaScript bridge.
           */
      ..addJavaScriptChannel(
        'ConsentBridge',
        onMessageReceived: (message) {
          if (_resultReceived) {
            return;
          }

          try {
            final decoded = jsonDecode(message.message);

            if (decoded is! Map<String, dynamic>) {
              throw const FormatException('Invalid consent response');
            }

            final result = WebConsentResult.fromJson(decoded);

            _resultReceived = true;

            widget.onResult(result);
          } catch (e) {
            _resultReceived = true;

            widget.onResult(
              WebConsentResult(
                ok: false,
                cancelled: false,
                allMandatoryGranted: false,
                message: e.toString(),
              ),
            );
          }
        },
      )
      /*
           * Navigation delegate.
           */
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            debugPrint('Consent WebView loaded: $url');

            _startConsent();
          },

          onWebResourceError: (error) {
            debugPrint(
              'Consent WebView error: '
              '${error.errorCode} '
              '${error.description}',
            );
          },
        ),
      )
      /*
           * Keep your working loadHtmlString approach.
           */
      ..loadHtmlString(
        _html,

        /*
             * Keep this because your original
             * implementation was working with it.
             */
        baseUrl: widget.apiBaseUrl,
      );
  }

  Future<void> _startConsent() async {
    if (_started) {
      return;
    }

    _started = true;

    final payload = jsonEncode({
      'apiBase': widget.apiBaseUrl,

      'clientId': widget.applicationKey,

      'noticeCode': widget.noticeCode,

      'email': widget.email ?? '',

      'mobile': widget.mobile ?? '',

      'fullName': widget.fullName ?? '',
    });

    /*
     * jsonEncode(payload) is intentional.
     *
     * payload itself is already a JSON string.
     */
    final javascript =
        'window.startConsentFromFlutter('
        '${jsonEncode(payload)}'
        ');';

    try {
      await _controller.runJavaScript(javascript);
    } catch (e) {
      if (_resultReceived) {
        return;
      }

      _resultReceived = true;

      widget.onResult(
        WebConsentResult(
          ok: false,
          cancelled: false,
          allMandatoryGranted: false,
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
