import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';

/// Base interface for all use cases
// ignore: one_member_abstracts
abstract base class UseCase<T, P> {
  const UseCase();
  
  Future<Either<Failure, T>> call(P params);
}

/// Use case that doesn't require parameters
// ignore: one_member_abstracts
abstract base class UseCaseNoParams<T> {
  const UseCaseNoParams();
  
  Future<Either<Failure, T>> call();
}

/// Base class for use case parameters
abstract class Params extends Equatable {
  const Params();
  
  @override
  List<Object?> get props => [];
}

/// Empty parameters class for use cases that don't need parameters
class NoParams extends Params {
  const NoParams();
}