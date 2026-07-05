import 'package:dio/dio.dart';

class NetworkExceptions {
  static String getMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'الاتصال اتأخر.. جربي تاني';
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          final data = error.response?.data;

          // لو الباك بيرجع message
          final msg = (data is Map && data['message'] is String)
              ? data['message'] as String
              : null;

          if (status == 400) return msg ?? 'بيانات غير صحيحة';
          if (status == 401) return 'غير مصرح.. اعملي تسجيل دخول تاني';
          if (status == 403) return 'ممنوع الوصول';
          if (status == 404) return 'المورد غير موجود';
          if (status != null && status >= 500) return 'مشكلة في السيرفر';
          return msg ?? 'حصل خطأ غير متوقع';
        case DioExceptionType.cancel:
          return 'تم إلغاء الطلب';
        case DioExceptionType.connectionError:
          return 'مفيش اتصال بالإنترنت';
        case DioExceptionType.unknown:
          return 'حصل خطأ.. جربي تاني';
        default:
          return 'حصل خطأ.. جربي تاني';
      }
    }
    return 'حصل خطأ غير متوقع';
  }
}
