import '../models/milestone_model.dart';

class MilestoneSampleData {
  static List<MilestoneModel> getMilestonesForRoute(String routeId) {
    switch (routeId) {
      case 'route_fansipan_01':
        return _fansipanMilestones;
      default:
        return _fansipanMilestones;
    }
  }

  static const List<MilestoneModel> _fansipanMilestones = [
    MilestoneModel(
      id: 'ms_fan_01',
      name: 'Trạm Tôn - Điểm xuất phát',
      sequence: 1,
      altitude: 1900,
      isCheckedIn: true,
    ),
    MilestoneModel(
      id: 'ms_fan_02',
      name: 'Trại nghỉ đêm 1 (2200m)',
      sequence: 2,
      altitude: 2200,
      isCheckedIn: true,
    ),
    MilestoneModel(
      id: 'ms_fan_03',
      name: 'Vọng Cảnh Đài',
      sequence: 3,
      altitude: 2600,
      isCheckedIn: false,
    ),
    MilestoneModel(
      id: 'ms_fan_04',
      name: 'Trại nghỉ đêm 2 (2800m)',
      sequence: 4,
      altitude: 2800,
      isCheckedIn: false,
    ),
    MilestoneModel(
      id: 'ms_fan_05',
      name: 'Đỉnh Fansipan - 3143m',
      sequence: 5,
      altitude: 3143,
      isCheckedIn: false,
    ),
  ];
}
