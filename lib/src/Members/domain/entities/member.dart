class Member {
  final String fullName;
  final String location;
  final String contact;
  final String marriageStatus;
  final String? spouseName;
  final List<String>? children;
  final String? relativeContact;
  final String? additionalImage;
  final String? profilePic;
  final DateTime dateOfBirth;

  Member({
    required this.fullName,
    required this.location,
    required this.contact,
    required this.marriageStatus,
    this.spouseName,
    this.children,
    this.relativeContact,
    this.additionalImage,
    this.profilePic,
    required this.dateOfBirth,
  });
}