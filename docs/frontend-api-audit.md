# Frontend API audit

> Historical snapshot. See [frontend-readiness-audit.md](frontend-readiness-audit.md)
> for current SQLite, sync, map package and UI verification on 12 October 2026.

## Connected screens

| Screen / action | Backend API |
| --- | --- |
| Explore list, search, region, ratings | GET /places?q=&region=&page=&limit= |
| Explore place details and route selection | GET /places/:id, GET /places/:id/routes |
| Route details | GET /routes/:id and place metadata |
| Home journey statistics / recently visited places | GET /journeys/statistics, GET /visits/places/me/recent, GET /places/:id |
| Profile, bio, avatar | GET /users/me, PATCH /users/me/bio, POST /users/me/avatar |
| Profile statistics, province visits, badges | GET /journeys/statistics, GET /visits/provinces/me, GET /badges, GET /badges/me |
| Language and theme settings | GET /users/me/settings, PATCH /users/me/settings |
| Suggest a place | POST /uploads/presign + storage upload, POST /contributions/places |
| Journey creation, list and lifecycle | GET/POST /journeys, POST /journeys/:id/{start,pause,resume,complete} |
| Milestone check-in | Device GPS, POST /checkins, GET /journeys/:id/checkins on checkin service |
| Place review from a journey | POST /places/:id/reviews, presigned image uploads |
| Offline package download | Route package manifest, download URL and checksum validation |

Explore includes debounced server search, paginated catalog retrieval, refresh, retry, and separate route-load errors. Place taps show all available routes instead of choosing the first route automatically. Featured/recommended sections reuse catalog results; there is no personalized recommendation API. Popular places follow rating order; routes have no independent popularity metric.

## Remaining demo data / limitations

- Community posts/comments still use sample data: no corresponding community backend service was found in this repository.
- `test_explore_detail_screen.dart` and sample datasource files remain as development fixtures; the active Explore navigation does not use them.
- Province map metadata is static geography, while visited state comes from the API.
- Downloading a package does not complete offline tile rendering or the pending offline sync worker. Marker media synchronization also remains separate work.
- Anonymous reviews are unavailable in the backend and disabled in the UI.
- No live authenticated backend/device test was performed. Automated tests use HTTP fixtures to check mapping, requests, failures and retry behavior; GPS and actual storage uploads require a device and running services.

## Verification

- Seven trekking frontend tests passed, covering catalog mapping/pagination, Explore partial failures and search, profile data, place submission retry IDs, bio failure handling and journey/milestone mapping.
- Full library analysis reported no compilation errors; existing warnings and style lints remain.
