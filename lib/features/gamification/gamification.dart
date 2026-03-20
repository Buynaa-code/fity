// Domain
export 'domain/entities/badge.dart' hide Badge;
export 'domain/entities/badge_definitions.dart';
export 'domain/repositories/badge_repository.dart';

// Data
export 'data/models/user_badge_model.dart';
export 'data/datasources/badge_local_datasource.dart';
export 'data/repositories/badge_repository_impl.dart';

// Presentation
export 'presentation/bloc/badge_bloc.dart';
export 'presentation/bloc/badge_event.dart';
export 'presentation/bloc/badge_state.dart';
export 'presentation/widgets/badge_card.dart';
export 'presentation/widgets/badge_unlock_animation.dart';
export 'presentation/pages/badges_screen.dart';
