import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

void _handleCommon3xx4xx5xxStatusCode(int statusCode, String responseText) {
  switch (statusCode) {
    case 400:
      throw BadRequestException("Bad Request: $responseText");
    case 401:
      throw UnauthorizedException("Unauthorized: $responseText");
    case 403:
      throw ForbiddenException("Forbidden: $responseText");
    case 404:
      throw NotFoundException("Not Found: $responseText");
    case 422:
      throw UnprocessableEntityException("Unprocessable Entity: $responseText");
    case 429:
      throw RateLimitException("Rate Limit Exceeded: $responseText");
    case 500:
      throw InternalServerErrorException(
          "Internal Server Error: $responseText");
    default:
      throw ApiException(statusCode, "Unexpected Error: $responseText");
  }
}

Future<dynamic> handleResponse(
  http.StreamedResponse response, {
  bool isStreamingRequest = false,
}) async {
  final status = response.statusCode;

  if (status >= 200 && status < 300) {
    if (isStreamingRequest) {
      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (line.startsWith("data: ")) {
          final jsonStr = line.substring("data: ".length).trim();
          return jsonDecode(jsonStr);
        } else if (line.startsWith("error: ")) {
          final errorStr = line.substring("error: ".length).trim();
          throw InternalServerErrorException(errorStr);
        }
      }

      throw ApiException(500, "Stream ended without a valid event.");
    } else {
      final bodyStr = await response.stream.bytesToString();

      if (bodyStr.isEmpty) return null;

      try {
        return jsonDecode(bodyStr);
      } catch (_) {
        return bodyStr;
      }
    }
  } else {
    final bodyStr = await response.stream.bytesToString();
    _handleCommon3xx4xx5xxStatusCode(status, bodyStr);
  }
}
