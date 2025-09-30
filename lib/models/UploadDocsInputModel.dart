class UploadDocsInputModel {
  final String id;
  final String title;
  final String? hintText; // Optional
  final List<String> allowedDocuments;
  final bool isCalendar; // To control if date pickers are shown


  UploadDocsInputModel({
    required this.id,
    required this.title,
    this.hintText,
    required this.allowedDocuments,
    required this.isCalendar,

  });
}

