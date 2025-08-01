import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/citation_model.dart';

part 'citation_provider.g.dart';

// Current citation being worked on
@riverpod
class CurrentCitation extends _$CurrentCitation {
  @override
  Citation build() => const Citation();

  void updateDriver(Map<String, dynamic> driverData) {
    state = state.copyWith(
      firstName: driverData['firstName'],
      lastName: driverData['lastName'],
      dlNumber: driverData['dlNumber'],
      dlState: driverData['dlState'],
      address: driverData['address'],
      city: driverData['city'],
      state: driverData['state'],
      zip: driverData['zip'],
    );
  }

  void updateVehicle(Map<String, dynamic> vehicleData) {
    state = state.copyWith(
      vehicleLicense: vehicleData['licensePlate'],
      vehicleState: vehicleData['plateState'],
      vin: vehicleData['vin'],
      vehicleYear: vehicleData['year'],
      vehicleMake: vehicleData['make'],
      vehicleModel: vehicleData['model'],
      vehicleColor: vehicleData['color'],
    );
  }

  void updateViolation(Map<String, dynamic> violationData) {
    state = state.copyWith(
      violationCode: violationData['code'],
      violationDescription: violationData['description'],
      location: violationData['location'],
      speed: violationData['speed'],
      speedLimit: violationData['speedLimit'],
    );
  }

  void reset() {
    state = const Citation();
  }
}

// Chat messages provider
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<Map<String, dynamic>> build() => [];

  void addMessage(Map<String, dynamic> message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }
}
