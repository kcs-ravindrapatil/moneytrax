import 'package:equatable/equatable.dart';

import '../error/failures.dart';

sealed class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Error() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error<T>(:final failure) => failure,
      };

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T data) onSuccess,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onFailure(failure),
    };
  }

  @override
  List<Object?> get props => [];
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
