import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<_DeviceTableState> deviceTableKey = GlobalKey();

class DeviceTable extends StatefulWidget {
  String selectedModelId;

  DeviceTable({Key? key, required this.selectedModelId}) : super(key: key);

  @override
  State<DeviceTable> createState() => _DeviceTableState();
}

class _DeviceTableState extends State<DeviceTable> {
  TextEditingController searchController = TextEditingController();

  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int numRowsPerPage = 10;
  List<Data> data = [
    Data(
      modelId: "modelId1",
      deviceId: "device1",
      deviceName: "Temperature Sensor",
      deviceType: "Temperature",
      location: "Room A",
      status: "Active",
      timestamp: "2023-01-15T08:30:00Z",
      data: {
        "temperature": 22.5,
        "humidity": 45.0,
      },
    ),
    Data(
      modelId: "modelId2",
      deviceId: "device2",
      deviceName: "Light Sensor",
      deviceType: "Light",
      location: "Room B",
      status: "Inactive",
      timestamp: "2023-01-15T09:15:00Z",
      data: {"lightLevel": 800},
    ),
    Data(
      modelId: "modelId3",
      deviceId: "device3",
      deviceName: "Motion Detector",
      deviceType: "Motion",
      location: "Corridor",
      status: "Active",
      timestamp: "2023-01-15T10:00:00Z",
      data: {"motionDetected": true},
    ),
    Data(
      modelId: "modelId4",
      deviceId: "device4",
      deviceName: "Pressure Sensor",
      deviceType: "Pressure",
      location: "Room C",
      status: "Active",
      timestamp: "2023-01-15T11:00:00Z",
      data: {"pressure": 1013.25},
    ),
  ];

  bool sortAscending = true;
  int sortColumnIndex = 0;
  List<String> modelIds = [];

  late List<Data> filterData;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _populateModelIds();
    _sortData();
    _filterData();
  }

  void updateFilter(String searchQuery) {
    setState(() {
      searchController.text = searchQuery;
      _filterData();
    });
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rowsPerPage =
          prefs.getInt('rowsPerPage') ?? PaginatedDataTable.defaultRowsPerPage;
      numRowsPerPage = prefs.getInt('numRowsPerPage') ?? numRowsPerPage;
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('rowsPerPage', rowsPerPage);
    prefs.setInt('numRowsPerPage', numRowsPerPage);
  }

  Future<void> _populateModelIds() async {
    List<String> ids = data.map((item) => item.modelId).toList();
    setState(() {
      modelIds = ids.toSet().toList();
    });
  }

  void _sortData() {
    data.sort((a, b) {
      if (widget.selectedModelId == a.modelId &&
          widget.selectedModelId != b.modelId) {
        return -1;
      } else if (widget.selectedModelId != a.modelId &&
          widget.selectedModelId == b.modelId) {
        return 1;
      } else {
        return a.modelId.compareTo(b.modelId);
      }
    });
  }

  void _filterData() {
    if (searchController.text.isEmpty) {
      filterData = List.from(data);
    } else {
      filterData = data
          .where((item) =>
              item.deviceId
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              item.deviceName
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              item.deviceType
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              item.location
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              item.status
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              item.timestamp
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              item.data.entries.any((entry) =>
                  entry.key
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()) ||
                  entry.value
                      .toString()
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase())))
          .toList();
    }

    _sortData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: widget.selectedModelId,
            onChanged: (value) {
              setState(() {
                widget.selectedModelId = value!;
                _sortData();
              });
            },
            items: modelIds.map((String id) {
              return DropdownMenuItem<String>(
                value: id,
                child: Text(id),
              );
            }).toList(),
          ),
        ),
        ListView(
          children: [
            PaginatedDataTable(
              rowsPerPage: rowsPerPage,
              onRowsPerPageChanged: (value) {
                setState(() {
                  rowsPerPage = value ?? PaginatedDataTable.defaultRowsPerPage;
                  _savePreferences();
                });
              },
              headingRowHeight: 35,
              dataRowHeight: 35,
              columns: [
                DataColumn(
                  label: const Text(
                    'Model ID',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onSort: (columnIndex, ascending) {
                    onSort(columnIndex, ascending);
                  },
                  numeric: false,
                ),
                DataColumn(
                  label: const Text(
                    'Device ID',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onSort: (columnIndex, ascending) {
                    onSort(columnIndex, ascending);
                  },
                  numeric: false,
                ),
                const DataColumn(
                  label: Text(
                    'Device Name',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  numeric: false,
                ),
                const DataColumn(
                  label: Text(
                    'Device Type',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  numeric: false,
                ),
                const DataColumn(
                  label: Text(
                    'Location',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  numeric: false,
                ),
                const DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  numeric: false,
                ),
                const DataColumn(
                  label: Text(
                    'Timestamp',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  numeric: false,
                ),
                const DataColumn(
                  label: Text(
                    'Values',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              source: MyData(filterData, widget.selectedModelId,
                  onTap: navigateToDeviceHistory),
            ),
          ],
        ),
      ],
    );
  }

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      data.sort((a, b) {
        if (ascending) {
          return a.modelId.compareTo(b.modelId);
        } else {
          return b.modelId.compareTo(a.modelId);
        }
      });
    }

    sortColumnIndex = columnIndex;
    sortAscending = ascending;

    setState(() {});
  }

  void navigateToDeviceHistory(String deviceId) {
    // Handle navigation to device history page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DeviceHistoryPage(deviceId: deviceId),
    //   ),
    // );
  }
}

class Data {
  final String modelId;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String location;
  final String status;
  final String timestamp;
  final Map<String, dynamic> data;

  Data({
    required this.modelId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.location,
    required this.status,
    required this.timestamp,
    required this.data,
  });
}

class MyData extends DataTableSource {
  final List<Data> data;
  String selectedModelId;
  final Function(String) onTap;

  MyData(this.data, this.selectedModelId, {required this.onTap});

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    final Data result = data[index];

    bool isSelectedModel = result.modelId == selectedModelId;
    TextStyle textStyle = isSelectedModel
        ? const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          )
        : const TextStyle(color: Colors.black);

    return DataRow(
      cells: [
        DataCell(Text(result.modelId, style: textStyle)),
        DataCell(
          Row(
            children: [
              Text(result.deviceId, style: textStyle),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  onTap(result.deviceId);
                },
                child: Icon(
                  Icons.remove_red_eye,
                  color: isSelectedModel ? Colors.blue : Colors.black,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(result.deviceName, style: textStyle)),
        DataCell(Text(result.deviceType, style: textStyle)),
        DataCell(Text(result.location, style: textStyle)),
        DataCell(Text(result.status, style: textStyle)),
        DataCell(Text(result.timestamp, style: textStyle)),
        DataCell(
          Wrap(
            direction: Axis.vertical,
            children: result.data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text("${entry.key}: ${entry.value}", style: textStyle),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
