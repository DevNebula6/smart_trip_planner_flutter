import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

// Result wrapper to handle success and failure states
class Result<T> {
  final T? data;
  final Failure? failure;
  final bool isSuccess;
  
  const Result._({this.data, this.failure, required this.isSuccess});
  
  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }
  
  factory Result.failure(Failure failure) {
    return Result._(failure: failure, isSuccess: false);
  }
  
  bool get isFailure => !isSuccess;
}

class NoParams {
  const NoParams();
}

// Generic response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });
  
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }
  
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
