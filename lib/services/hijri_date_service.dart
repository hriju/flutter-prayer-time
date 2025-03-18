import 'package:cloud_firestore/cloud_firestore.dart';

class HijriDateService {
  // Comment out Firebase collection reference
  // final CollectionReference _hijriMonthStartsCollection =
  //     FirebaseFirestore.instance.collection('hijriMonthStarts');

  Future<Map<String, dynamic>?> fetchHijriMonthStarts(int gregorianYear) async {
    // Mock data instead of fetching from Firebase
    return {
      'Muharram': '2023-07-19',
      'Safar': '2023-08-18',
      'Rabi al-Awwal': '2023-09-16',
      'Rabi al-Thani': '2023-10-16',
      'Jumada al-Awwal': '2023-11-15',
      'Jumada al-Thani': '2023-12-14',
      'Rajab': '2024-01-13',
      'Shaban': '2024-02-11',
      'Ramadan': '2024-03-12',
      'Shawwal': '2024-04-10',
      'Dhu al-Qadah': '2024-05-10',
      'Dhu al-Hijjah': '2024-06-08',
    };
    
    // Original Firebase code
    /*
    DocumentSnapshot snapshot = await _hijriMonthStartsCollection.doc(gregorianYear.toString()).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>?;
    }
    return null;
    */
  }

  Future<String> calculateHijriDate(DateTime gregorianDate) async {
    // For simplicity, return a mock Hijri date
    return '15 Ramadan';
    
    // Original code
    /*
    int year = gregorianDate.year;

    // Fetch data for the current year and the previous year to handle overlap
    Map<String, dynamic>? monthStarts = await fetchHijriMonthStarts(year);

    if (monthStarts == null) {
      throw Exception('No data available for the provided date.');
    }

    String hijriDate = '';
    DateTime closestStartDate = DateTime.parse('1970-01-01');
    DateTime monthStartDate = DateTime.parse('1970-01-01');
    String month = '';

    monthStarts.forEach((monthName, startDate) {
      monthStartDate = DateTime.parse(startDate);
      if (gregorianDate.isAfter(monthStartDate) || gregorianDate.isAtSameMomentAs(monthStartDate)) {
        if (monthStartDate.isAfter(closestStartDate) || monthStartDate.isAtSameMomentAs(closestStartDate)) {
          closestStartDate = monthStartDate;
          month = monthName;
        }
      }
    });

    int daysPassed = gregorianDate.difference(closestStartDate).inDays;
    hijriDate = '${daysPassed + 1} $month';

    return hijriDate;
    */
  }
}
