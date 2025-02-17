import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../Constants/locationData.dart';
import '../../Models/locationHistoryDataModel.dart';

class SetOfficeLocationBloc
    extends Bloc<SetOfficeLocationEvent, SetOfficeLocationState> {
  SetOfficeLocationBloc() : super(SetOfficeLocationInitial()) {
    on<SetOfficeLocationInitialEvent>((event, emit) {
      // TODO: implement event handler
      final location =
          LocationTempData.officeLocation ?? LocationHistoryDataModel();

      emit(SetOfficeLocationChanged(location: location));
    });

    on<SetOfficeLocationChangedEvent>((event, emit) {
      LocationTempData.officeLocation = event.location;
      emit(SetOfficeLocationChanged(location: event.location));
    });
  }
}

@immutable
sealed class SetOfficeLocationEvent {}

class SetOfficeLocationInitialEvent extends SetOfficeLocationEvent {}

class SetOfficeLocationChangedEvent extends SetOfficeLocationEvent {
  final LocationHistoryDataModel location;
  SetOfficeLocationChangedEvent({
    required this.location,
  });
}

@immutable
sealed class SetOfficeLocationState {}

final class SetOfficeLocationInitial extends SetOfficeLocationState {}

final class SetOfficeLocationChanged extends SetOfficeLocationState {
  final LocationHistoryDataModel location;

  SetOfficeLocationChanged({required this.location});
}
