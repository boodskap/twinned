import 'package:flutter/material.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/pages/widgets/events_dropdown.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class EventRegistrationDialog extends StatefulWidget {
  const EventRegistrationDialog({super.key});

  @override
  _EventRegistrationDialogState createState() =>
      _EventRegistrationDialogState();
}

class _EventRegistrationDialogState extends State<EventRegistrationDialog> {
  final TextEditingController _nameController = TextEditingController();
  String selectedEvent = 'Select Event';
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _notificationCheckbox = false;
  bool _emailCheckbox = true;
  bool _smsCheckbox = false;
  bool _voiceCheckbox = false;
  bool _fcmCheckbox = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validateEventId(String? value) {
    if (value == null || value.isEmpty || value == 'Select Event') {
      return 'Event ID is required';
    }
    return null;
  }

  String? _validateEmailId(String? value) {
    if (_emailCheckbox && (value == null || value.isEmpty)) {
      return 'Email ID is required';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if ((_smsCheckbox || _voiceCheckbox) && (value == null || value.isEmpty)) {
      return 'Phone Number is required';
    }
    return null;
  }

  void _addNewEntity(BuildContext context) async {
    try {
      if (_formKey.currentState?.validate() != true) {
        // Form validation failed, do not proceed
        return;
      }

      EventRegistrationInfo info = EventRegistrationInfo(
        eventId: selectedEvent,
        notification: _notificationCheckbox,
        email: _emailCheckbox,
        sms: _smsCheckbox,
        voice: _voiceCheckbox,
        fcm: _fcmCheckbox,
        emailId: _emailCheckbox ? _emailIdController.text : null,
        phoneNumber: (_smsCheckbox || _voiceCheckbox)
            ? _phoneNumberController.text
            : null,
        name: _nameController.text,
        targetDeviceIds: null,
        tags: null,
      );

      var res = await UserSession.twin.createEventRegistration(
        apikey: UserSession().getAuthToken(),
        body: info,
      );

      Navigator.of(context).pop();
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Add Event Registration'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                EventModelDropDown(
                  valueChanged: (String? newValue) {
                    setState(() {
                      selectedEvent = newValue!;
                    });
                  },
                  onModelSelected: (String? selected) {
                    // Handle the selected event, if needed
                  },
                  initialValue: selectedEvent,
                  validator: (String? value) {
                    if (value == null ||
                        value.isEmpty ||
                        value == 'Select Event') {
                      return 'Event Model is required';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  title: const Text('Notification'),
                  value: _notificationCheckbox,
                  onChanged: (bool? value) {
                    setState(() {
                      _notificationCheckbox = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Email'),
                  value: _emailCheckbox,
                  onChanged: (bool? value) {
                    setState(() {
                      _emailCheckbox = value ?? false;
                    });
                  },
                ),
                if (_emailCheckbox)
                  TextFormField(
                    controller: _emailIdController,
                    decoration: const InputDecoration(labelText: 'Email ID'),
                    validator: _validateEmailId,
                  ),
                CheckboxListTile(
                  title: const Text('SMS'),
                  value: _smsCheckbox,
                  onChanged: (bool? value) {
                    setState(() {
                      _smsCheckbox = value ?? false;
                    });
                  },
                ),
                if (_smsCheckbox || _voiceCheckbox)
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    validator: _validatePhoneNumber,
                  ),
                CheckboxListTile(
                  title: const Text('Voice'),
                  value: _voiceCheckbox,
                  onChanged: (bool? value) {
                    setState(() {
                      _voiceCheckbox = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('FCM'),
                  value: _fcmCheckbox,
                  onChanged: (bool? value) {
                    setState(() {
                      _fcmCheckbox = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _addNewEntity(context);
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: const Text('Submit'),
        )
      ],
    );
  }
}
