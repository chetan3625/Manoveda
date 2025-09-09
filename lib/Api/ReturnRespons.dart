
class ReturnDynamicResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ReturnDynamicResponse({
    required this.success,
    required this.message,
    required this.data,
  });
}
