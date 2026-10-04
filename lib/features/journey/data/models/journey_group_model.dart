import 'journey_model.dart';

class JourneyGroupModel {
  final DateTime date;
  final List<JourneyModel> journeys;

  const JourneyGroupModel({
    required this.date,
    required this.journeys,
  });

  String formatMonthYear([String languageCode = 'vi']) {
    if (languageCode == 'en') {
      const months = [
        'JANUARY',
        'FEBRUARY',
        'MARCH',
        'APRIL',
        'MAY',
        'JUNE',
        'JULY',
        'AUGUST',
        'SEPTEMBER',
        'OCTOBER',
        'NOVEMBER',
        'DECEMBER'
      ];
      return '${months[date.month - 1]}, ${date.year}';//thang truoc ngay sau
    }
    return 'THÁNG ${date.month}, ${date.year}';//ngay truoc thang sau
  }
}
