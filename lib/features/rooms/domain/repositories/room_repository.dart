import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';

abstract class RoomRepository {
  Future<Either<Failure, List<Room>>> getRooms();
  Future<Either<Failure, Room>> getRoom(String id);
  Future<Either<Failure, Room>> createRoom(Room room);
  Future<Either<Failure, Room>> updateRoom(Room room);
  Future<Either<Failure, void>> deleteRoom(String id);
}
