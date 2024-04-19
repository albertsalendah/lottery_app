import 'package:lottery_app/model/lotter_model.dart';

int getCommonLength(List<LotterModel> items) {
  // Create a map to store the frequency of each length
  Map<int, int> lengthFrequency = {};

  // Populate the map with the frequency of each length
  for (var item in items) {
    int length = item.number.length;
    lengthFrequency[length] = (lengthFrequency[length] ?? 0) + 1;
  }

  // Find the maximum frequency and the corresponding lengths
  int maxFrequency = 0;
  List<int> maxLengths = [];
  lengthFrequency.forEach((length, frequency) {
    if (frequency > maxFrequency) {
      maxFrequency = frequency;
      maxLengths = [length];
    } else if (frequency == maxFrequency) {
      maxLengths.add(length);
    }
  });

  int result = maxLengths.reduce((curr, next) => curr > next ? curr : next);

  items.removeWhere((element) => element.number.length != result);

  RegExp hasLetter = RegExp(r'[A-Za-z]');

  // Remove items that contain letters
  items.removeWhere((item) => hasLetter.hasMatch(item.number));

  // Return the longest length among the ones with the maximum frequency
  return result;
}
