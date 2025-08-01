import 'package:flutter/foundation.dart';

@immutable
class Citation {
  // Driver Information
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? dlNumber;
  final String? dlState;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? zip;

  // Vehicle Information
  final String? vehicleLicense;
  final String? vehicleState;
  final String? vin;
  final String? vehicleYear;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? bodyStyle;

  // Violation Information
  final DateTime? violationDate;
  final String? violationTime;
  final String? location;
  final String? cityCounty;
  final String? violationCode;
  final String? violationDescription;
  final String? speed;
  final String? speedLimit;
  final bool? radarUsed;

  // Officer Information
  final String? officerName;
  final String? officerBadge;
  final String? agency;

  // Citation Details
  final bool? appearInCourt;
  final DateTime? courtDate;
  final String? courtName;
  final String? courtAddress;

  const Citation({
    this.firstName,
    this.middleName,
    this.lastName,
    this.dlNumber,
    this.dlState,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.vehicleLicense,
    this.vehicleState,
    this.vin,
    this.vehicleYear,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.bodyStyle,
    this.violationDate,
    this.violationTime,
    this.location,
    this.cityCounty,
    this.violationCode,
    this.violationDescription,
    this.speed,
    this.speedLimit,
    this.radarUsed,
    this.officerName,
    this.officerBadge,
    this.agency,
    this.appearInCourt,
    this.courtDate,
    this.courtName,
    this.courtAddress,
  });

  Citation copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? dlNumber,
    String? dlState,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? vehicleLicense,
    String? vehicleState,
    String? vin,
    String? vehicleYear,
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleColor,
    String? bodyStyle,
    DateTime? violationDate,
    String? violationTime,
    String? location,
    String? cityCounty,
    String? violationCode,
    String? violationDescription,
    String? speed,
    String? speedLimit,
    bool? radarUsed,
    String? officerName,
    String? officerBadge,
    String? agency,
    bool? appearInCourt,
    DateTime? courtDate,
    String? courtName,
    String? courtAddress,
  }) {
    return Citation(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      dlNumber: dlNumber ?? this.dlNumber,
      dlState: dlState ?? this.dlState,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      vehicleLicense: vehicleLicense ?? this.vehicleLicense,
      vehicleState: vehicleState ?? this.vehicleState,
      vin: vin ?? this.vin,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      violationDate: violationDate ?? this.violationDate,
      violationTime: violationTime ?? this.violationTime,
      location: location ?? this.location,
      cityCounty: cityCounty ?? this.cityCounty,
      violationCode: violationCode ?? this.violationCode,
      violationDescription: violationDescription ?? this.violationDescription,
      speed: speed ?? this.speed,
      speedLimit: speedLimit ?? this.speedLimit,
      radarUsed: radarUsed ?? this.radarUsed,
      officerName: officerName ?? this.officerName,
      officerBadge: officerBadge ?? this.officerBadge,
      agency: agency ?? this.agency,
      appearInCourt: appearInCourt ?? this.appearInCourt,
      courtDate: courtDate ?? this.courtDate,
      courtName: courtName ?? this.courtName,
      courtAddress: courtAddress ?? this.courtAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dlNumber': dlNumber,
      'dlState': dlState,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'vehicleLicense': vehicleLicense,
      'vehicleState': vehicleState,
      'vin': vin,
      'vehicleYear': vehicleYear,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'bodyStyle': bodyStyle,
      'violationDate': violationDate?.toIso8601String(),
      'violationTime': violationTime,
      'location': location,
      'cityCounty': cityCounty,
      'violationCode': violationCode,
      'violationDescription': violationDescription,
      'speed': speed,
      'speedLimit': speedLimit,
      'radarUsed': radarUsed,
      'officerName': officerName,
      'officerBadge': officerBadge,
      'agency': agency,
      'appearInCourt': appearInCourt,
      'courtDate': courtDate?.toIso8601String(),
      'courtName': courtName,
      'courtAddress': courtAddress,
    };
  }
}
