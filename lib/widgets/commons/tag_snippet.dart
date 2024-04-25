import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:nocode_commons/core/base_state.dart';

final TextStyle _labelPopupTextStyle = GoogleFonts.acme(
  color: Colors.black,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);
const Color primaryColor = Color(0xFF0C244A);
const Color secondaryColor = Color(0xFFFFFFFF);

class TagList extends StatefulWidget {
  final List<twinned.Lookup> tagDataList;
  final Function(List<twinned.Lookup>) onSave;

  const TagList({Key? key, required this.tagDataList, required this.onSave})
      : super(key: key);
  @override
  _TagListState createState() => _TagListState();
}

class _TagListState extends State<TagList> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 1.0,
      runSpacing: 5.0,
      children: widget.tagDataList.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return data.attributes != null
            ? TagWidget(
                tagData: data,
                onSave: widget.onSave,
                onTagRemoved: () {},
                settingsIndex: index,
                currentDataList:
                    widget.tagDataList // Pass the index to TagWidget
                )
            : const Text("");
      }).toList(),
    );
  }
}

class TagWidget extends StatelessWidget {
  final twinned.Lookup tagData;
  final VoidCallback? onTagRemoved;
  final Function(List<twinned.Lookup>) onSave;
  final int settingsIndex;
  final List<twinned.Lookup> currentDataList;
  // final List<twinned.Lookup> list;
  const TagWidget({
    super.key,
    required this.tagData,
    this.onTagRemoved,
    required this.onSave,
    required this.settingsIndex,
    required this.currentDataList,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Tooltip(
        message: tagData.name,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: secondaryColor,
              border: Border.all(color: primaryColor)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tagData.name,
                style: const TextStyle(color: primaryColor, fontSize: 12),
              ),
              const SizedBox(width: 4.0),
              InkWell(
                onTap: () {},
                child: const Icon(
                  Icons.edit,
                  color: primaryColor,
                  size: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableDialog extends StatefulWidget {
  final twinned.SettingsInfo settings;
  final Function(List<twinned.Lookup>) onSave;
  final String name;
  final int settingsIndex;
  final List<twinned.Lookup> currentDataList;

  const TableDialog({
    Key? key,
    required this.settings,
    required this.onSave,
    required this.name,
    required this.settingsIndex,
    required this.currentDataList,
  }) : super(key: key);

  @override
  _TableDialogState createState() => _TableDialogState();
}

class _TableDialogState extends BaseState<TableDialog> {
  List<TableRow> rows = [];
  List<TableRow> paramHeaders = [];
  List<twinned.Attribute> paramList = [];
  bool apiLoadingStatus = false;
  String settingsName = "";
  List<TextEditingController> controllers = [];
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    paramList.clear();
    try {
      settingsName = widget.settings.name;
      paramList.addAll(widget.settings.attributes!);
      controllers = List.generate(
        paramList.length,
        (index) => TextEditingController(text: paramList[index].$value ?? ''),
      );
      setState(() {
        apiLoadingStatus = true;
      });
    } catch (e, x) {
      debugPrint('$e');
      debugPrint('$x');
    }
  }

  @override
  Widget build(BuildContext context) {
    return apiLoadingStatus
        ? AlertDialog(
            title: Text(
              "Settings Table - $settingsName",
              style: _labelPopupTextStyle.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTableRow(context),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: secondaryColor),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: secondaryColor),
                ),
                onPressed: () {
                  _saveSettings();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: primaryColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget _buildTableRow(BuildContext context) {
    rows.clear();
    paramHeaders.add(const TableRow(children: [
      Center(
        child: Text(
          'Name',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Description',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Label',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Type',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Value',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    ]));
    rows.add(paramHeaders.first);

    void buildRow(int index, var param) {
      TableRow row = TableRow(children: [
        Align(alignment: Alignment.center, child: Text(param.name)),
        Align(
          alignment: Alignment.center,
          child: Text(param.description ?? ''),
        ),
        Align(alignment: Alignment.center, child: Text(param.label ?? '')),
        Align(
          alignment: Alignment.center,
          child: Text(param.attributeType.value),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              enabled: param.editable ?? true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              controller: controllers[index],
              onChanged: (newValue) {},
            ),
          ),
        ),
      ]);
      rows.add(row);
    }

    for (var i = 0; i < paramList.length; i++) {
      buildRow(i, paramList[i]);
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Table(
        border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(2),
          5: FlexColumnWidth(1),
        },
        children: rows,
      ),
    );
  }

  void _saveSettings() {}

  @override
  void setup() {
    // TODO: implement setup
  }
}

void _showTableDialog(
    BuildContext context,
    twinned.SettingsInfo settings,
    Function(List<twinned.Lookup>) onSave,
    String name,
    int settingsIndex,
    List<twinned.Lookup> currentDataList) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return TableDialog(
          settings: settings,
          onSave: onSave,
          name: name,
          settingsIndex: settingsIndex,
          currentDataList: currentDataList);
    },
  );
}
