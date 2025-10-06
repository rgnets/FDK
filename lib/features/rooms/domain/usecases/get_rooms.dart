import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/usecases/usecase.dart';
import 'package:rgnets_fdk/features/rooms/domain/entities/room.dart';
import 'package:rgnets_fdk/features/rooms/domain/repositories/room_repository.dart';

final class GetRooms extends UseCaseNoParams<List<Room>> {
  GetRooms(this.repository);

  final RoomRepository repository;

  @override
  Future<Either<Failure, List<Room>>> call() async {
    return repository.getRooms();
  }
}