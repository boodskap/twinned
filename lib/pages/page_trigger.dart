import 'dart:math';

import 'package:flutter/material.dart';

class TriggerPage extends StatefulWidget {
  const TriggerPage({Key? key}) : super(key: key);

  @override
  State<TriggerPage> createState() => _TriggerPageState();
}

class _TriggerPageState extends State<TriggerPage>
    with SingleTickerProviderStateMixin {
  late Image bannerImage;

  bool sortAscending = true;

  @override
  void initState() {
    super.initState();

    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );
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
        Expanded(
          flex: 20,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 8),
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        onChanged: (String value) {},
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 50.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Trigger Icon',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Device Icon',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'State Icon',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Hardware Id',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Delivery Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Action',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _buildTableRows().length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: _buildTableRows()[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTableRows() {
    List<Map<String, String>> tableData = [
      {
        'Name': 'Event 1',
        'Type': 'Voice',
        'Hardware Id': 'Keerthika',
        'Delivery Status': '{"status":"Processing"}',
        'CStamp': '2023-12-02 12:30:05',
        'RStamp': '2023-12-02 12:30:30',
        'EventDescription': 'This is the event description',
        'ModelDescription': 'This is the model description',
      },
      {
        'Name': 'Event 2',
        'Type': 'SMS',
        'Hardware Id': 'Keerthika',
        'Delivery Status': '{"status":"Recieved"}',
        'CStamp': '2023-12-02 12:30:05',
        'RStamp': '2023-12-02 12:30:55',
        'EventDescription': 'This is the event description',
        'ModelDescription': 'This is the model description',
      },
      {
        'Name': 'Event 1',
        'Type': 'Voice',
        'Hardware Id': 'Keerthika',
        'Delivery Status': '{"status":"sent"}',
        'CStamp': '2023-12-02 12:30:05',
        'RStamp': '2023-12-03 02:30:30',
        'EventDescription': 'This is the event description',
        'ModelDescription': 'This is the model description',
      },
    ];

    List<Map<String, String>> last25Devices =
        tableData.sublist(max(0, tableData.length - 25));

    return last25Devices.map((data) {
      DateTime reportingStamp = DateTime.parse(data['CStamp']!);
      DateTime processedStamp = DateTime.parse(data['RStamp']!);
      Duration difference = processedStamp.difference(reportingStamp);

      Color stateColor = Colors.green;
      if (difference.inSeconds <= 45) {
        stateColor = Colors.green;
      } else if (difference.inSeconds <= 59) {
        stateColor = Colors.orange;
      } else {
        stateColor = Colors.red;
      }

      return ExpansionTile(
        title: Row(
          children: [
            const Expanded(
              child: Icon(
                Icons.device_thermostat,
                color: Colors.black,
              ),
            ),
            const Expanded(
              child: Icon(
                Icons.devices_other,
                color: Colors.black,
              ),
            ),
           Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 35.0),
                child: Tooltip(
                  message: () {
                    if (stateColor == Colors.green &&
                        difference.inSeconds <= 45) {
                      return 'Less than 45';
                    } else if (stateColor == Colors.orange &&
                        difference.inSeconds > 45) {
                      return 'Greater than 45 ';
                    } else if (stateColor == Colors.red &&
                        difference.inSeconds > 60) {
                      return 'Greater than 60';
                    }
                  }(),
                  child: CircleAvatar(
                    backgroundColor: stateColor,
                    radius: 8,
                  ),
                ),
              ),
            ),
            
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(data['Hardware Id'] ?? ''),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(data['Delivery Status'] ?? ''),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Container(
            color: Colors.amber,
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: double.maxFinite,
                    child: Center(
                      child: Image.asset(
                        'assets/images/genset.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: double.maxFinite,
                    color: Colors.green,
                    child: const Center(child: Text('Condition')),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: double.maxFinite,
                    color: Colors.blue,
                    child: const Center(child: Text('Errors')),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }).toList();
  }
}
