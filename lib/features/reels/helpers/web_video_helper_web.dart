import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

bool _swRegistered = false;
bool _swFailed = false;

Future<bool> _ensureServiceWorker(Map<String, String> headers) async {
  if (_swFailed) return false;

  try {
    if (!_swRegistered) {
      final registration = await web.window.navigator.serviceWorker
          .register('reel-stream-sw.js'.toJS)
          .toDart;

      final sw = registration.active ?? registration.installing ?? registration.waiting;
      if (sw != null && sw.state != 'activated') {
        final completer = Completer<void>();
        sw.onstatechange = ((web.Event _) {
          if (sw.state == 'activated') completer.complete();
        }).toJS;
        await completer.future.timeout(const Duration(seconds: 5));
      }
      _swRegistered = true;
    }

    final controller = web.window.navigator.serviceWorker.controller;
    if (controller != null) {
      final jsHeaders = <String, String>{};
      headers.forEach((key, value) {
        jsHeaders[key] = value;
      });
      controller.postMessage({
        'type': 'SET_AUTH_HEADERS',
        'headers': jsHeaders,
      }.jsify());
      return true;
    }
  } catch (_) {
    _swFailed = true;
  }
  return false;
}

Future<String?> fetchVideoAsBlobUrl(String url, Map<String, String> headers) async {
  final bool swReady = await _ensureServiceWorker(headers);
  if (swReady) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}__reel_stream__=1';
  }

  try {
    final jsHeaders = web.Headers();
    headers.forEach((key, value) {
      jsHeaders.append(key, value);
    });
    final response = await web.window
        .fetch(url.toJS, web.RequestInit(method: 'GET', headers: jsHeaders))
        .toDart;
    if (!response.ok) return null;
    final blob = await response.blob().toDart;
    return web.URL.createObjectURL(blob);
  } catch (_) {}
  return null;
}

void revokeBlobUrl(String url) {
  if (url.startsWith('blob:')) {
    try {
      web.URL.revokeObjectURL(url);
    } catch (_) {}
  }
}
