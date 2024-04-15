import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class EventModelDropDown extends StatefulWidget {
  final void Function(String?) valueChanged;
  final void Function(String?) onModelSelected;
  final String? initialValue;
  final String? Function(String?)? validator;

  const EventModelDropDown({
    Key? key,
    required this.valueChanged,
    required this.onModelSelected,
    this.initialValue,
    this.validator,
  }) : super(key: key);

  @override
  State<EventModelDropDown> createState() => _EventModelDropDownState();
}

class _EventModelDropDownState extends BaseState<EventModelDropDown> {
  List<Map<String, dynamic>> _eventList = [];
  String? selectedEvent = 'Select Event';

  @override
  void setup() async {
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      var res = await UserSession.twin.listEvents(
        apikey: UserSession().getAuthToken(),
        body: const ListReq(page: 0, size: 1000),
      );

      setState(() {
        _eventList = (res.body?.values ?? []).map((event) {
          return {
            "id": event.id,
            "name": event.name,
          };
        }).toList();

        // Set _selected to the first event in the list
        if (_eventList.isNotEmpty) {
          selectedEvent = _eventList.first["id"];
        }
      });
    } catch (e, x) {
      debugPrint('$e');
      debugPrint('$x');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedEvent,
        onChanged: (String? newValue) {
          setState(() {
            selectedEvent = newValue;
            widget.valueChanged(newValue);
          });
        },
        validator: widget.validator,
        items: _eventList.map<DropdownMenuItem<String>>((event) {
          String eventId = event["id"].toString();
          String eventName = event["name"].toString();

          return DropdownMenuItem<String>(
            value: eventId,
            child: Text(eventName),
          );
        }).toList(),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
