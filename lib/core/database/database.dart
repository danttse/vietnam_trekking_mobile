/// Database layer barrel export.
///
/// Import duy nhất 1 file này để dùng toàn bộ SQLite layer:
///
/// ```dart
/// import 'package:vietnam_trekking_mobile/core/database/database.dart';
/// ```
library;

// Core
export 'database_helper.dart';

// Models — Local Identity
export 'models/local_user.dart';

// Models — Cache
export 'models/cached_province.dart';
export 'models/cached_place.dart';
export 'models/cached_route.dart';
export 'models/cached_milestone.dart';

// Models — Journey Tracking
export 'models/local_journey.dart';
export 'models/track_point.dart';
export 'models/local_journey_marker.dart';
export 'models/local_marker_media.dart';
export 'models/offline_checkin.dart';

// Models — Offline Data
export 'models/visited_province.dart';
export 'models/downloaded_map.dart';

// Models — Sync
export 'models/sync_queue_item.dart';
export 'models/local_contribution.dart';

// DAOs
export 'daos/local_user_dao.dart';
export 'daos/cache_dao.dart';
export 'daos/journey_dao.dart';
export 'daos/marker_dao.dart';
export 'daos/checkin_dao.dart';
export 'daos/offline_data_dao.dart';
export 'daos/sync_dao.dart';
