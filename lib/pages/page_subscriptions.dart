import 'package:chopper/src/response.dart';
import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends BaseState<SubscriptionsPage> {
  late Image bannerImage;
  final List<Widget> _rows = [];
  List<Event> _events = [];
  List<EventRegistration> _eventRegistrations = [];

  EventRegistration dummy = const EventRegistration(
    domainKey: '',
    id: '',
    name: '',
    rtype: '',
    createdStamp: 0,
    createdBy: '',
    updatedBy: '',
    updatedStamp: 0,
    eventId: '',
    userId: '',
  );

  @override
  void initState() {
    super.initState();

    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );
  }

  @override
  void setup() {
    _load();
  }

  void _load() async {
    busy();
    var pR = UserSession().loginResponse!;

    try {
      await _loadEvents();
      await _loadEventRegistrations();

      for (int i = 0; i < _events.length; i++) {
        var temp = _eventRegistrations
            .where((element) => _events[i].id == element.eventId)
            .toList();

        ER er;
        if (temp.isNotEmpty) {
          er = ER(event: _events[i], eventRegistration: temp[0]);
        } else {
          er = ER(event: _events[i], eventRegistration: dummy);
        }

        _buildRow(er, i + 1);
      }

      refresh();
    } catch (e) {
      alert('Error', e.toString());
    }

    busy(busy: false);
  }

  Future<void> _loadEvents() async {
    _rows.clear();
    _events.clear();

    var res = await UserSession.twin.listEvents(
      apikey: UserSession().getAuthToken(),
      body: const ListReq(page: 0, size: 10000),
    );

    if (validateResponse(res)) {
      _events = res.body!.values!;
    }
  }

  Future<void> _loadEventRegistrations() async {
    _eventRegistrations.clear();

    var res = await UserSession.twin.listEventRegistrations(
      apikey: UserSession().getAuthToken(),
      body: const ListReq(page: 0, size: 10000),
    );

    if (validateResponse(res)) {
      _eventRegistrations = res.body!.values!;
    }
  }

  void _upsertEventRegistration(
    String key,
    bool value,
    String id,
    String eventId,
    EventRegistration eventRegistration,
  ) async {
    busy();
    debugPrint('**** upsert calling ****');

    EventRegistrationInfo evInfo;
    Response<EventRegistrationEntityRes> res;

    bool isEmail = false;
    bool isSms = false;
    bool isVoice = false;

    try {
      switch (key) {
        case 'email':
          isEmail = true;
          break;
        case 'sms':
          isSms = true;
          break;
        case 'voice':
          isVoice = true;
          break;
        default:
          break;
      }

      if (id.isNotEmpty) {
        evInfo = EventRegistrationInfo(
          eventId: eventId,
          email: isEmail ? value : eventRegistration.email,
          sms: isSms ? value : eventRegistration.sms,
          voice: isVoice ? value : eventRegistration.voice,
          notification: eventRegistration.notification,
          fcm: eventRegistration.fcm,
          emailId: eventRegistration.emailId,
          phoneNumber: eventRegistration.phoneNumber,
          name: eventRegistration.name,
          targetDeviceIds: eventRegistration.targetDeviceIds,
          tags: eventRegistration.tags,
        );

        res = await UserSession.twin.updateEventRegistration(
          eventRegistrationId: id,
          body: evInfo,
          apikey: UserSession().getAuthToken(),
        );
      } else {
        evInfo = EventRegistrationInfo(
          eventId: eventId,
          email: isEmail ? value : false,
          sms: isSms ? value : false,
          voice: isVoice ? value : false,
          notification: false,
          fcm: false,
          emailId: UserSession().loginResponse!.user!.email,
          phoneNumber: '0000000000',
          name: 'name',
          targetDeviceIds: [],
          tags: [],
        );

        res = await UserSession.twin.createEventRegistration(
          body: evInfo,
          apikey: UserSession().getAuthToken(),
        );
      }

      if (validateResponse(res)) {
        setup();
        // alert('Success', 'Event Registered');
      }
    } catch (e) {
      alert('Error', e.toString());
    }

    busy(busy: false);
  }

  void _removeEventRegistration(String id) async {
    busy();
    debugPrint('*** delete calling ***');

    try {
      var res = await UserSession.twin.deleteEventRegistration(
        eventRegistrationId: id,
        apikey: UserSession().getAuthToken(),
      );

      if (validateResponse(res)) {
        setup();
        // alert('Success', 'Event Registration Deleted');
      }
    } catch (e) {
      debugPrint(e.toString());
      alert('Error', e.toString());
    }

    busy(busy: false);
  }

  void _buildRow(ER er, int sl) {
    bool subscribed = er.eventRegistration!.id.isNotEmpty;
    bool email = false;
    bool sms = false;
    bool voice = false;

    if (subscribed) {
      email = er.eventRegistration!.email ?? false;
      sms = er.eventRegistration!.sms ?? false;
      voice = er.eventRegistration!.voice ?? false;
    }

    Widget newRow = SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: Text("$sl"),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        er.event!.name.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Email'),
                      const SizedBox(width: 10),
                      Checkbox(
                        value: email,
                        onChanged: (value) {
                          setState(() {
                            email = value!;
                          });
                          debugPrint('*************');
                          debugPrint(email.toString());
                          debugPrint(er.event.toString());
                          debugPrint(er.eventRegistration.toString());
                          debugPrint('isNotEmpty $email $sms $voice');

                          bool isNotEmpty = email || sms || voice;

                          if (isNotEmpty) {
                            _upsertEventRegistration(
                              'email',
                              email,
                              er.eventRegistration!.id,
                              er.event!.id,
                              er.eventRegistration!,
                            );
                          } else {
                            _removeEventRegistration(er.eventRegistration!.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('SMS'),
                      const SizedBox(width: 10),
                      Checkbox(
                        value: sms,
                        onChanged: (value) {
                          setState(() {
                            sms = value!;
                          });
                          debugPrint('*************');
                          debugPrint(sms.toString());
                          debugPrint(er.event.toString());
                          debugPrint(er.eventRegistration.toString());
                          debugPrint('isNotEmpty $email $sms $voice');

                          bool isNotEmpty = email || sms || voice;

                          if (isNotEmpty) {
                            _upsertEventRegistration(
                              'sms',
                              sms,
                              er.eventRegistration!.id,
                              er.event!.id,
                              er.eventRegistration!,
                            );
                          } else {
                            _removeEventRegistration(er.eventRegistration!.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Voice'),
                      const SizedBox(width: 10),
                      Checkbox(
                        value: voice,
                        onChanged: (value) {
                          setState(() {
                            voice = value!;
                          });
                          debugPrint('*************');
                          debugPrint(voice.toString());
                          debugPrint(er.event.toString());
                          debugPrint(er.eventRegistration.toString());
                          debugPrint('isNotEmpty $email $sms $voice');

                          bool isNotEmpty = email || sms || voice;

                          if (isNotEmpty) {
                            _upsertEventRegistration(
                              'voice',
                              voice,
                              er.eventRegistration!.id,
                              er.event!.id,
                              er.eventRegistration!,
                            );
                          } else {
                            _removeEventRegistration(er.eventRegistration!.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, thickness: 0.5, height: 0)
        ],
      ),
    );

    setState(() {
      _rows.add(newRow);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: bannerImage,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _rows.length,
              itemBuilder: (context, index) {
                return _rows[index];
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ER {
  Event? event;
  EventRegistration? eventRegistration;

  ER({this.event, this.eventRegistration});

  // Map<String, dynamic> toJson() {
  //   Map<String, dynamic> map = {
  //     'event': event,
  //     'eventRegistration': eventRegistration
  //   };
  //   return map;
  // }

  static ER fromJson(Event ev, EventRegistration er) {
    return ER(event: ev, eventRegistration: er);
  }
}
