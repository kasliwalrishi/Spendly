// contact_model.dart
import 'package:hive/hive.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

part 'contacts_adapter.g.dart';

@HiveType(typeId: 10)
class HiveContact extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String displayName;

  @HiveField(2)
  late List<HivePhone> phones;

  @HiveField(3)
  late List<HiveEmail> emails;

  HiveContact({
    required this.id,
    required this.displayName,
    List<HivePhone>? phones,
    List<HiveEmail>? emails,
  }) {
    this.phones = phones ?? [];
    this.emails = emails ?? [];
  }

  // Convert from Flutter Contact to HiveContact
  factory HiveContact.fromContact(Contact contact) {
    return HiveContact(id: contact.id, displayName: contact.displayName)
      ..phones = contact.phones.map((p) => HivePhone(number: p.number)).toList()
      ..emails =
          contact.emails.map((e) => HiveEmail(address: e.address)).toList();
  }

  Contact toContact() {
    return Contact(
      id: id,
      displayName: displayName,
      phones: phones.map((p) => Phone(p.number)).toList(),
      emails: emails.map((e) => Email(e.address)).toList(),
    );
  }
}

@HiveType(typeId: 11)
class HivePhone extends HiveObject {
  @HiveField(0)
  late String number;

  @HiveField(1)
  late String label;

  HivePhone({
    required this.number,
    this.label = '',
  });
}

@HiveType(typeId: 12)
class HiveEmail extends HiveObject {
  @HiveField(0)
  late String address;

  @HiveField(1)
  late String label;

  HiveEmail({
    required this.address,
    this.label = '',
  });
}
