import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class GetDdipEvents {
  final DdipEventRepository repository;

  GetDdipEvents({required this.repository});

  Future<List<DdipEvent>> call({required NLatLngBounds bounds}) async {
    return await repository.getDdipEvents(bounds: bounds);
  }
}
