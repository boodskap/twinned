import 'dart:math';

import 'package:flutter/material.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:twin_commons/core/base_state.dart';
import 'package:intl/intl.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends BaseState<EventPage>
    with SingleTickerProviderStateMixin {
  late Image bannerImage;
  String search = "*";

  bool sortAscending = true;
  int _currentPage = 1;
  int _selectedRowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 20, 50, 100];
  List<twin.TriggeredEvent> tableData = [];
  TextEditingController searchController = TextEditingController();
  void _onRowsPerPageChanged(int? newRowsPerPage) {
    if (newRowsPerPage != null) {
      setState(() {
        _selectedRowsPerPage = newRowsPerPage;
        _currentPage = 1;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );
    setup();
  }

  @override
  void setup() async {
    if (search.trim().isEmpty) {
      search = '*';
    }
    try {
      var res = await UserSession.twin.seearchTriggeredEvents(
          apikey: UserSession().getAuthToken(),
          body: twin.FilterSearchReq(
              search: search, page: 0, filter: null, size: 100));

      if (validateResponse(res)) {
        setState(() {
          tableData = res.body!.values!;
        });
      }
    } catch (e, x) {
      debugPrint('$e');
      debugPrint('$x');
    }
  }

  void _updatePage(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
    setup();
  }

  void _refreshPage() {
    search = '*';
    searchController.text = "";
    setup();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Widget> _getPageData(int startIndex, int endIndex) {
    int adjustedEndIndex = endIndex < _buildTableRows().length
        ? endIndex
        : _buildTableRows().length;

    return _buildTableRows().sublist(startIndex, adjustedEndIndex);
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = (_currentPage - 1) * _selectedRowsPerPage;
    int endIndex = startIndex + _selectedRowsPerPage;

    List<Widget> currentPageData = _getPageData(startIndex, endIndex);

    currentPageData = currentPageData.asMap().entries.map((entry) {
      int index = entry.key;
      Widget eventData = entry.value;

      return eventData;
    }).toList();
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
                  IconButton(
                      tooltip: 'Reload Data',
                      onPressed: () {
                        _refreshPage();
                      },
                      icon: const Icon(Icons.refresh)),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 300,
                      height: 30,
                      child: SearchBar(
                          hintText: 'Search',
                          controller: searchController,
                          onChanged: (String value) {
                            search = value.isEmpty ? '*' : value;
                            setup();
                          }),
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
                      flex: 1,
                      child: Text(
                        'Icon',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Created Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Updated Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Type',
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
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentPageData.length,
                  itemBuilder: (BuildContext context, int index) {
                    int overallIndex = startIndex + index;
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
                      child: _buildTableRows()[overallIndex],
                    );
                  },
                ),
              ),
              CustomPagination(
                total: _buildTableRows().length,
                rowsPerPage: _selectedRowsPerPage,
                currentPage: _currentPage,
                onPageChanged: _updatePage,
                onRowsPerPageChanged: _onRowsPerPageChanged,
                rowsPerPageOptions: _rowsPerPageOptions,
                selectedRowsPerPage: _selectedRowsPerPage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTableRows() {
    List<twin.TriggeredEvent> last25Devices =
        tableData.sublist(max(0, tableData.length - 25));

    return last25Devices.map((data) {
      DateTime reportingStamp =
          DateTime.fromMillisecondsSinceEpoch(data.createdStamp);
      DateTime processedStamp =
          DateTime.fromMillisecondsSinceEpoch(data.updatedStamp);

      String reportingStampDate =
          DateFormat('MM/dd/yyyy h:mm a').format(reportingStamp);
      String processedStampDate =
          DateFormat('MM/dd/yyyy h:mm a').format(reportingStamp);

      // DateTime reportingStamp = DateTime.parse(data.createdStamp.toString()!);
      // DateTime reportingStamp = DateTime.parse(data.createdStamp.toString());
      // DateTime processedStamp = DateTime.parse(data.updatedStamp.toString());
      // Duration difference = processedStamp.difference(reportingStamp);

      Color stateColor = Colors.green;
      // if (difference.inSeconds <= 45) {
      //   stateColor = Colors.green;
      // } else if (difference.inSeconds <= 59) {
      //   stateColor = Colors.orange;
      // } else {
      //   stateColor = Colors.red;
      // }

      return ExpansionTile(
        title: Row(
          children: [
            const Expanded(
              flex: 1,
              child: Icon(
                Icons.device_thermostat,
                color: Colors.black,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Row(
                  children: [
                    Text(reportingStampDate.toString()),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Row(
                  children: [
                    Text(processedStampDate.toString()),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(data.name),
                  const SizedBox(width: 5),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Row(
                  children: [
                    Text(data.eventType.value.toString()),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(data.deliveryStatus.value.toString()),
              ),
            ),
          ],
        ),
        children: [
          SizedBox(
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: double.maxFinite,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email Subject:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${data.emailSubject}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Email Content:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${data.emailContent}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: double.maxFinite,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SMS:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${data.smsMessage}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: double.maxFinite,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Voice:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${data.voiceMessage}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class CustomPagination extends StatelessWidget {
  final int total;
  final int rowsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;
  final List<int> rowsPerPageOptions;
  final int selectedRowsPerPage;

  const CustomPagination({
    super.key,
    required this.total,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.rowsPerPageOptions,
    required this.selectedRowsPerPage,
  });

  @override
  Widget build(BuildContext context) {
    int totalPages = (total / rowsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: $total'),
          Row(
            children: [
              DropdownButton<int>(
                value: selectedRowsPerPage,
                items: rowsPerPageOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
                onChanged: onRowsPerPageChanged,
              ),
              const SizedBox(width: 16.0),
              Text('Page $currentPage of $totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
