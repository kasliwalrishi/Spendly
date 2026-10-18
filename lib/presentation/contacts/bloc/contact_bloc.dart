import 'package:fingenie/core/services/hive/service/contact_service.dart';
import 'package:fingenie/presentation/contacts/bloc/contact_events.dart';
import 'package:fingenie/presentation/contacts/bloc/contact_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactsService _contactsService;

  ContactsBloc({ContactsService? contactsService})
      : _contactsService = contactsService ?? ContactsService(),
        super(ContactsState()) {
    on<FetchContactsEvent>(_onFetchContacts);
    on<RefreshContactsEvent>(_onRefreshContacts);
    // on<ClearCachedContactsEvent>(_onClearCachedContacts);
  }

  Future<void> _onFetchContacts(
      FetchContactsEvent event, Emitter<ContactsState> emit) async {
    if (!await Permission.contacts.request().isGranted) {
      emit(state.copyWith(
          errorMessage: 'Contacts permission denied', isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final contacts = await _contactsService.fetchAndCacheContacts();

      emit(state.copyWith(contacts: contacts, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'Error fetching contacts: ${e.toString()}',
          isLoading: false));
    }
  }

  Future<void> _onRefreshContacts(
      RefreshContactsEvent event, Emitter<ContactsState> emit) async {
    add(FetchContactsEvent());
  }

  // Future<void> _onClearCachedContacts(
  //   ClearCachedContactsEvent event,
  //   Emitter<ContactsState> emit
  // ) async {
  //   // Clear cached contacts
  //   await _contactsService.clearCachedContacts();

  //   // Trigger fresh fetch
  //   add(FetchContactsEvent());
  // }
}
