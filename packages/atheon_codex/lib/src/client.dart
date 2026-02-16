import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';
import '_internal.dart';
import 'models.dart';

class AtheonCodexClientOptions {
  final String apiKey;
  final String? baseUrl;
  final Map<String, String>? headers;

  /// Supported keys:
  /// - `cookies`: Map<String, String> - Added to the 'Cookie' header.
  /// - `params`: Map<String, dynamic> - Merged with URL query parameters.
  /// - `headers`: Map<String, String> - Merged with request headers.
  /// - `timeout`: int - Request timeout in milliseconds.
  /// - `followRedirects`: bool
  /// - `maxRedirects`: int
  /// - `persistentConnection`: bool
  final Map<String, dynamic>? kwargs;

  AtheonCodexClientOptions({
    required this.apiKey,
    this.baseUrl,
    this.headers,
    this.kwargs,
  });
}

class AtheonCodexClient {
  late final String _baseUrl;
  late final Map<String, String> _headers;
  late final Map<String, dynamic> _kwargs;
  final http.Client _httpClient;

  AtheonCodexClient(AtheonCodexClientOptions options, {http.Client? client})
      : _httpClient = client ?? http.Client() {
    _baseUrl = options.baseUrl ?? "https://api.atheon.ad/v1";
    _headers = {
      "x-atheon-api-key": options.apiKey,
      "Content-Type": "application/json",
      ...?options.headers,
    };
    _kwargs = options.kwargs ?? {};
  }

  void close() {
    _httpClient.close();
  }

  void _mergeKwargsToRequest(
      http.Request request, Map<String, dynamic> kwargs) {
    // Handle Cookies ('cookies')
    if (kwargs.containsKey('cookies') && kwargs['cookies'] is Map) {
      final Map<String, dynamic> cookies = kwargs['cookies'];
      final cookieHeader =
          cookies.entries.map((e) => "${e.key}=${e.value}").join("; ");

      if (request.headers.containsKey('cookie')) {
        request.headers['cookie'] =
            "${request.headers['cookie']}; $cookieHeader";
      } else {
        request.headers['cookie'] = cookieHeader;
      }
    }

    // Handle Headers ('headers')
    if (kwargs.containsKey('headers') && kwargs['headers'] is Map) {
      final Map<String, String> headers =
          Map<String, String>.from(kwargs['headers']);
      request.headers.addAll(headers);
    }

    // Handle Standard Request Options
    if (kwargs['followRedirects'] is bool) {
      request.followRedirects = kwargs['followRedirects'];
    }
    if (kwargs['maxRedirects'] is int) {
      request.maxRedirects = kwargs['maxRedirects'];
    }
    if (kwargs['persistentConnection'] is bool) {
      request.persistentConnection = kwargs['persistentConnection'];
    }
  }

  Future<dynamic> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? jsonPayload,
    bool isStreamingRequest = false,
    int timeout = 45000,
  }) async {
    if (_kwargs.containsKey('timeout') && _kwargs['timeout'] is int) {
      timeout = _kwargs['timeout'];
    }

    Uri uri = Uri.parse("$_baseUrl$endpoint");
    if (_kwargs.containsKey('params') && _kwargs['params'] is Map) {
      final Map<String, dynamic> params = _kwargs['params'];

      final newQueryParameters = Map<String, dynamic>.from(uri.queryParameters);
      newQueryParameters
          .addAll(params.map((k, v) => MapEntry(k, v.toString())));

      uri = uri.replace(queryParameters: newQueryParameters);
    }

    final headers = {..._headers};
    if (isStreamingRequest) {
      if (method != "GET") {
        throw ApiException(
            400, "Streaming requests only support the GET method.");
      }
      headers["Accept"] = "text/event-stream";
    }

    // Build Request
    final request = http.Request(method, uri);
    request.headers.addAll(headers);

    if (jsonPayload != null && !isStreamingRequest) {
      request.body = jsonEncode(jsonPayload);
    }

    // Apply rest of the _kwargs (cookies, headers, options) to the request object
    _mergeKwargsToRequest(request, _kwargs);

    try {
      final streamedResponse = await _httpClient.send(request).timeout(
        Duration(milliseconds: timeout),
        onTimeout: () {
          throw ApiException(408, "Request timed out after ${timeout}ms");
        },
      );

      return await handleResponse(streamedResponse,
          isStreamingRequest: isStreamingRequest);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, "Network or Unexpected Error: $e");
    }
  }

  Future<dynamic> fetchAndIntegrateAtheonUnit(
    AtheonUnitFetchAndIntegrateModel payload,
  ) async {
    return await _makeRequest(
      "POST",
      "/track-units/fetch-and-integrate",
      jsonPayload: payload.toJson(),
    );
  }
}
