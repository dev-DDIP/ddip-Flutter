import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

class GetDdipEvents {
  final DdipEventRepository repository;

  GetDdipEvents({required this.repository});

  Future<List<DdipEvent>> call() async {
    return await repository.getDdipEvents();
  }
}