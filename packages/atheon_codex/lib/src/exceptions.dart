class ApiException implements Exception {
  final int status;
  final String? detail;

  ApiException(this.status, [this.detail]);

  @override
  String toString() {
    return detail != null
        ? "$runtimeType: $detail (Status: $status)"
        : "$runtimeType: Request failed with status $status";
  }
}

class BadRequestException extends ApiException {
  BadRequestException([String? detail]) : super(400, detail ?? "Bad Request");
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String? detail])
      : super(401, detail ?? "Unauthorized");
}

class ForbiddenException extends ApiException {
  ForbiddenException([String? detail]) : super(403, detail ?? "Forbidden");
}

class NotFoundException extends ApiException {
  NotFoundException([String? detail]) : super(404, detail ?? "Not Found");
}

class UnprocessableEntityException extends ApiException {
  UnprocessableEntityException([String? detail])
      : super(422, detail ?? "Unprocessable Entity");
}

class RateLimitException extends ApiException {
  RateLimitException([String? detail])
      : super(429, detail ?? "Rate Limit Exceeded");
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException([String? detail])
      : super(500, detail ?? "Internal Server Error");
}
