import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'call_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final status = await Permission.contacts.status;
      if (status.isGranted) {
        final contacts = await ContactsService.getContacts();
        setState(() {
          _contacts = contacts.toList();
          _contacts.sort((a, b) => a.displayName?.compareTo(b.displayName ?? '') ?? 0);
          _isLoading = false;
        });
      } else if (status.isDenied) {
        final result = await Permission.contacts.request();
        if (result.isGranted) {
          await _loadContacts();
        } else {
          setState(() {
            _errorMessage = 'Permission to access contacts was denied';
            _isLoading = false;
          });
        }
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _errorMessage = 'Contact permission is permanently denied, please enable it in app settings';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading contacts: $e';
        _isLoading = false;
      });
    }
  }

  void _callContact(Contact contact) {
    final phoneNumber = contact.phones?.first.value;
    if (phoneNumber != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            phoneNumber: phoneNumber,
            contactName: contact.displayName ?? 'Unknown',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available for this contact')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade50],
            stops: const [0.0, 1.0],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContacts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_contacts.isEmpty) {
      return const Center(child: Text('No contacts found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          color: Colors.white.withOpacity(0.9),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: _buildContactAvatar(contact),
            title: Text(
              contact.displayName ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              contact.phones?.isNotEmpty == true
                  ? contact.phones!.first.value ?? ''
                  : 'No phone number',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            trailing: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: () => _callContact(contact),
              ),
            ),
            onTap: () => _callContact(contact),
          ),
        );
      },
    );
  }

  Widget _buildContactAvatar(Contact contact) {
    if (contact.avatar != null && contact.avatar!.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundImage: MemoryImage(contact.avatar!),
          radius: 24,
        ),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.blue.shade100],
          ),
          border: Border.all(color: Colors.blue.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            contact.initials(),
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
    }
  }
}