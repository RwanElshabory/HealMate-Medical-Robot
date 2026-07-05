class ApiResult<T> {
  final T? data;
  final String? error;

  const ApiResult._({this.data, this.error});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.failure(String message) => ApiResult._(error: message);

  bool get isSuccess => data != null;
}
