import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/contribution_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/repositories/journey_repository.dart';
import 'package:vietnam_trekking_mobile/features/journey/viewmodels/contribution_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';

class FakeRepository extends JourneyRepository {
  final String status;
  SubmitRouteContributionRequest? sent;
  FakeRepository(this.status);
  @override
  Future<ContributionModel> submitRouteContribution(
    SubmitRouteContributionRequest request, {
    required String userId,
  }) async {
    sent = request;
    return ContributionModel(
      contributionId: 'saved',
      type: 'ROUTE_SUBMISSION',
      status: status,
    );
  }
}

void main() {
  test(
    'marker-only contribution can be sent during an active journey',
    () async {
      final repo = FakeRepository('PENDING_REVIEW');
      final vm = ContributionViewModel(
        userId: 'owner',
        repo: repo,
        markerOnly: true,
      );
      vm.setProposedName('Các cột mốc');
      vm.selectedMarkerIds = ['local-marker'];
      final route = RouteModel.fromJson({
        'trekkingRouteId': 'route',
        'trekkingPlaceId': 'place',
        'name': 'Route',
      });
      expect(
        await vm.submitRouteContribution(
          JourneyModel(
            journeyId: 'journey',
            name: 'Trip',
            route: route,
            userId: 'owner',
            status: JourneyStatus.active,
          ),
        ),
        isTrue,
      );
      expect(repo.sent!.toJson()['contributionKind'], 'MARKERS');
      vm.dispose();
    },
  );
  for (final status in ['DRAFT', 'PENDING_REVIEW']) {
    test(
      'submission $status has an accurate queued or received state and includes selected markers',
      () async {
        final repo = FakeRepository(status);
        final vm = ContributionViewModel(userId: 'owner', repo: repo);
        vm.setProposedName('Cung đường thử');
        vm.selectedMarkerIds = ['local-marker'];
        final route = RouteModel.fromJson({
          'trekkingRouteId': 'route',
          'trekkingPlaceId': 'place',
          'name': 'Route',
        });
        final journey = JourneyModel(
          journeyId: 'journey',
          name: 'Trip',
          route: route,
          userId: 'owner',
          status: JourneyStatus.completed,
        );
        expect(await vm.submitRouteContribution(journey), isTrue);
        expect(
          vm.submitState,
          status == 'DRAFT'
              ? ContributionSubmitState.queued
              : ContributionSubmitState.success,
        );
        expect(vm.error, isNull);
        expect(repo.sent!.markerIds, ['local-marker']);
        vm.dispose();
      },
    );
  }
}
