import 'package:dio/dio.dart';

class ErrorParser {
  ErrorParser._();

  static String parseLogin(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 400) {
        return 'Incorrect phone number or password. Please try again.';
      }
    }
    return parse(e);
  }

  static String parse(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      if (status == 401) return 'Session expired. Please log in again.';
      if (status == 400) return 'Bad request. Please try again.';
      if (status == 403) return 'You do not have permission to do that.';
      if (status == 404) return 'Resource not found.';
      if (status != null && status >= 500) {
        return 'Server error. Please try again later.';
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'No internet connection. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
