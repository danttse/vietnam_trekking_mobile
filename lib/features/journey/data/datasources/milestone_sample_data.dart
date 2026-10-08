import '../models/milestone_model.dart';

class MilestoneSampleData {
  static List<MilestoneModel> getMilestonesForRoute(String routeId) {
    switch (routeId) {
      case 'route_tanang_01':
        return _tanangMilestones;
      case 'route_fansipan_01':
        return _fansipanMilestones;
      default:
        return _tanangMilestones;
    }
  }

  static const List<MilestoneModel> _tanangMilestones = [
    MilestoneModel(
      id: 'ms_tan_01',
      name: 'Bìa rừng Tà Năng',
      sequence: 1,
      altitude: 900,
      isCheckedIn: true,
    ),
    MilestoneModel(
      id: 'ms_tan_02',
      name: 'Mốc 2 tỉnh (Tà Năng)',
      sequence: 2,
      altitude: 1100,
      isCheckedIn: false,
    ),
    MilestoneModel(
      id: 'ms_tan_03',
      name: 'Đồi lính Tà Năng',
      sequence: 3,
      altitude: 1400,
      isCheckedIn: false,
    ),
    MilestoneModel(
      id: 'ms_tan_04',
      name: 'Đồi cỏ cháy Phan Dũng',
      sequence: 4,
      altitude: 800,
      isCheckedIn: false,
    ),
    MilestoneModel(
      id: 'ms_tan_05',
      name: 'Thác Lao Phào',
      sequence: 5,
      altitude: 500,
      isCheckedIn: false,
    ),
  ];

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
