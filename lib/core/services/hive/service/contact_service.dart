import 'package:fingenie/core/services/hive/adapter/contacts_adapter.dart';
import 'package:fingenie/utils/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsService {
  static const String _contactsBoxName = 'contacts_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _lastSyncKey = 'last_sync_timestamp';

  static const int _contactTypeId = 10;
  static const int _phoneTypeId = 11;
  static const int _emailTypeId = 12;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();

    // Register the adapters if they haven't been registered yet
    if (!Hive.isAdapterRegistered(_contactTypeId)) {
      Hive.registerAdapter(HiveContactAdapter());
    }
    if (!Hive.isAdapterRegistered(_phoneTypeId)) {
      Hive.registerAdapter(HivePhoneAdapter());
    }
    if (!Hive.isAdapterRegistered(_emailTypeId)) {
      Hive.registerAdapter(HiveEmailAdapter());
    }

    // Open boxes
    await Hive.openBox<HiveContact>(_contactsBoxName);
    await Hive.openBox(_settingsBoxName);
    AppLogger.success('ContactsService: Hive initialized successfully');
  }

  Future<bool> shouldRefreshContacts() async {
    AppLogger.info(
        'shouldRefreshContacts: Checking if contacts should be refreshed');
    final settingsBox = Hive.box(_settingsBoxName);
    final lastSync = settingsBox.get(_lastSyncKey) as int?;

    if (lastSync == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    const twentyFourHours = 24 * 60 * 60 * 1000;
    AppLogger.info(
        'shouldRefreshContacts: returning: (now - lastSync > twentyFourHours)');

    return now - lastSync > twentyFourHours;
  }

  // Fetch and cache contacts
  Future<List<Contact>> fetchAndCacheContacts() async {
    if (await shouldRefreshContacts()) {
      try {
        AppLogger.info('fetchAndCacheContacts: Fetching contacts');
        final contacts = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: false);
        AppLogger.success('fetchAndCacheContacts: Contacts fetched');
        print(contacts);
        AppLogger.info('fetchAndCacheContacts: waiting for cacheContacts');

        await cacheContacts(contacts);

        AppLogger.success('fetchAndCacheContacts: Contacts fetched and cached');
        return contacts;
      } catch (e) {
        AppLogger.error('fetchAndCacheContacts: $e');
        return getCachedContacts();
      }
    }

    return getCachedContacts();
  }

  Future<void> cacheContacts(List<Contact> contacts) async {
    AppLogger.info('cacheContacts: Caching contacts');
    final contactsBox = Hive.box<HiveContact>(_contactsBoxName);
    final settingsBox = Hive.box(_settingsBoxName);

    await contactsBox.clear();

    for (var contact in contacts) {
      final hiveContact = HiveContact.fromContact(contact);
      await contactsBox.put(hiveContact.id, hiveContact);
    }

    await settingsBox.put(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    AppLogger.success('cacheContacts: Cached successfully');
  }

  // Get cached contacts
  Future<List<Contact>> getCachedContacts() async {
    AppLogger.info('getCachedContacts: Getting cached contacts');
    final contactsBox = Hive.box<HiveContact>(_contactsBoxName);
    AppLogger.success('getCachedContacts: Contacts fetched');

    return contactsBox.values
        .map((hiveContact) => hiveContact.toContact())
        .toList();
  }

  Future<void> clearCachedContacts() async {
    final contactsBox = Hive.box<HiveContact>(_contactsBoxName);
    final settingsBox = Hive.box(_settingsBoxName);

    await contactsBox.clear();
    await settingsBox.delete(_lastSyncKey);
  }
}
