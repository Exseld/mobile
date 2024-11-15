class CalendarDay {
  final int? semaine;
  final int jourSemaine;
  final String special;

  CalendarDay({required this.semaine, required this.jourSemaine, required this.special});

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      semaine: json['semaine'],
      jourSemaine: json['jour_semaine'],
      special: json['special'],
    );
  }
}