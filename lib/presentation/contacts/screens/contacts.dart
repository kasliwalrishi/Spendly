import 'package:fingenie/presentation/contacts/bloc/contact_bloc.dart';
import 'package:fingenie/presentation/contacts/bloc/contact_events.dart';
import 'package:fingenie/presentation/contacts/bloc/contact_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactsBloc()..add(FetchContactsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
          actions: [
            // Refresh Button
            BlocBuilder<ContactsBloc, ContactsState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: state.isLoading
                      ? null
                      : () => context
                          .read<ContactsBloc>()
                          .add(RefreshContactsEvent()),
                );
              },
            ),
            // Clear Cache Button
            // BlocBuilder<ContactsBloc, ContactsState>(
            //   builder: (context, state) {
            //     return IconButton(
            //       icon: const Icon(Icons.delete_sweep),
            //       onPressed: state.isLoading
            //           ? null
            //           : () => context
            //               .read<ContactsBloc>()
            //               .add(ClearCachedContactsEvent()),
            //     );
            //   },
            // ),
          ],
        ),
        body: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state) {
            // Loading state
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (state.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ContactsBloc>()
                          .add(FetchContactsEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Empty state
            if (state.contacts.isEmpty) {
              return const Center(child: Text('No contacts found'));
            }

            // Contacts list
            return ListView.builder(
              itemCount: state.contacts.length,
              itemBuilder: (context, index) {
                final contact = state.contacts[index];
                return ListTile(
                  title: Text(contact.displayName),
                  subtitle: contact.phones.isNotEmpty
                      ? Text(contact.phones.first.number)
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
