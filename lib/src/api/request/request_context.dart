import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelfster/src/api/exceptions/api_exception.dart';
import 'package:shelfster/src/api/route/http_method.dart';
import 'package:shelf/shelf.dart';

part 'request_parameters.dart';

class RequestContext {
  RequestContext(this.request, this.routePattern) {
    params = RequestParameters(
      query: uri.queryParameters,
      uriSegments: url.pathSegments,
      routePattern: routePattern,
      body: _json(),
    );
  }

  final String routePattern;

  late final RequestParameters params;

  Request request;

  Uri get url => request.url;

  Uri get uri => request.requestedUri;

  Map<String, String> get headers => request.headers;

  HttpMethod get method => HttpMethod.values.firstWhere(
        (e) => e.name == request.method,
      );

  bool get isSocketConnection => request.headers['Upgrade'] == 'websocket';

  String? get ip {
    final forwardedFor = request.headers['X-Forwarded-For'];
    if (forwardedFor != null && forwardedFor.isNotEmpty) {
      return forwardedFor;
    }
    final connectionInfo = request.context['shelf.io.connection_info'];
    if (connectionInfo is HttpConnectionInfo) {
      return connectionInfo.remoteAddress.address;
    }
    return null;
  }

  String? get bearer {
    final value = request.headers['Authorization']?.split(' ');

    if (value != null && value.length == 2 && value.first == 'Bearer') {
      return value.last;
    }

    return null;
  }

  String? get deviceName => request.headers['User-Agent'];

  Map<String, String>? cookies() {
    final cookieString = request.headers['Cookie'];
    if (cookieString == null) return null;

    final cookiesEntries = cookieString.split('; ').map((cookie) {
      final [key, value] = cookie.split('=');
      return MapEntry(key, value);
    });

    return Map.fromEntries(cookiesEntries);
  }

  Future<String> _body() async {
    const requestBodyKey = 'dle.request.body';
    final bodyFromContext =
        request.context[requestBodyKey] as Completer<String>?;
    if (bodyFromContext != null) return bodyFromContext.future;

    final completer = Completer<String>();
    try {
      request = request.change(
        context: {...request.context, requestBodyKey: completer},
      );
      completer.complete(await request.readAsString());
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    }
    return completer.future;
  }

  Future<Map<String, dynamic>> _json() async {
    final String body = await _body();

    if (body.isEmpty) return {};

    final dynamic json = jsonDecode(await _body());
    try {
      json as Map<String, dynamic>;
    } catch (e) {
      throw const ApiException.badRequest('Invalid body data type.');
    }

    return json;
  }
}
