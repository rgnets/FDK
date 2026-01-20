/// Room Readiness feature - provides room-level readiness metrics
/// based on device status and onboarding completion.
library room_readiness;

// Domain layer
export 'domain/entities/entities.dart';
export 'domain/repositories/room_readiness_repository.dart';
export 'domain/usecases/usecases.dart';

// Data layer
export 'data/datasources/room_readiness_data_source.dart';
export 'data/datasources/room_readiness_mock_data_source.dart';
export 'data/repositories/room_readiness_repository_impl.dart';

// Presentation layer
export 'presentation/providers/room_readiness_provider.dart';
export 'presentation/screens/screens.dart';
export 'presentation/widgets/widgets.dart';
