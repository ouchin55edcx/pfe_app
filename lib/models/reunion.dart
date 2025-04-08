class Reunion {
  final String id;
  final String title;
  final String description;
  final String date;
  final String startTime;
  final String endTime;
  final String location;
  final String createdBy;
  final String createdAt;
  final String updatedAt;
  final String status;

  Reunion({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory Reunion.fromJson(Map<String, dynamic> json) {
    return Reunion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      status: json['status'],
    );
  }
}