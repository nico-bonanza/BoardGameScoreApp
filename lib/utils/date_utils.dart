// 年月日に変換して返す
String formattedToday(DateTime date) {
  return '${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日';
}
