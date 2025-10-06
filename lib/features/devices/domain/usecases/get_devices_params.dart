import 'package:equatable/equatable.dart';

/// Parameters for GetDevices use case
class GetDevicesParams extends Equatable {
  const GetDevicesParams({
    this.fields,
  });

  /// Optional field selection for API optimization
  final List<String>? fields;

  @override
  List<Object?> get props => [fields];
}