import 'package:ch_db_admin/shared/failure.dart';
import 'package:ch_db_admin/src/events/domain/entities/event.dart';
import 'package:ch_db_admin/src/events/domain/repository/event_repo.dart';
import 'package:dartz/dartz.dart';

class CreateEvent {
  final EventRepo eventRepo;

  CreateEvent({required this.eventRepo});

  Future<Either<Failure, String>> execute(Event event) {
    return eventRepo.createEvent(event);
  }
}