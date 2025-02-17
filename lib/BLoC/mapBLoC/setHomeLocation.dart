import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../Constants/locationData.dart';
import '../../Models/locationHistoryDataModel.dart';

class SetHomeLocationBloc
    extends Bloc<SetHomeLocationEvent, SetHomeLocationState> {
  SetHomeLocationBloc() : super(SetHomeLocationInitial()) {
    on<SetHomeLocationInitEvent>((event, emit) {
      // TODO: implement event handler

      final location = LocationTempData.homeLocation;

      emit(SetHomeLocationChange(
          location: location ?? LocationHistoryDataModel()));
    });

    on<SetHomeLocationChangeEvent>((event, emit) {
      // TODO: implement event handler
      LocationTempData.homeLocation = event.locationHistoryDataModel;

      emit(SetHomeLocationChange(location: event.locationHistoryDataModel));
    });
  }
}

@immutable
sealed class SetHomeLocationEvent {}

class SetHomeLocationInitEvent extends SetHomeLocationEvent {}

class SetHomeLocationChangeEvent extends SetHomeLocationEvent {
  final LocationHistoryDataModel locationHistoryDataModel;

  SetHomeLocationChangeEvent({
    required this.locationHistoryDataModel,
  });
}

@immutable
sealed class SetHomeLocationState {}

final class SetHomeLocationInitial extends SetHomeLocationState {
  // final LocationHistoryDataModel location;

  // SetHomeLocationInitial(this.location);
}

final class SetHomeLocationChange extends SetHomeLocationState {
  final LocationHistoryDataModel location;

  SetHomeLocationChange({required this.location});
}
