import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twinned/providers/state_provider.dart';

class SimulatorDialogScreen extends StatefulWidget {
  const SimulatorDialogScreen({super.key});

  @override
  State<SimulatorDialogScreen> createState() => _SimulatorDialogScreenState();
}

class _SimulatorDialogScreenState extends State<SimulatorDialogScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          _showSimulatorDialog(context);
        },
        child: const Text('Show'),
      ),
    );
  }

  void _showSimulatorDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Simulator'),
            content: SizedBox(
              width: 600,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 30,
                      child: Text('Text'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 30,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Text',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Boolean'),
                    Expanded(
                      flex: 30,
                      child: Transform.scale(
                        scale: 0.7,
                        child: Consumer<StateProvider>(
                          builder: (BuildContext context, values, child) =>
                              Switch(
                            value: values.isTrue,
                            activeColor: Colors.blue,
                            onChanged: (bool value) {
                              print(value);
                              values.check(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Expanded(
                      flex: 30,
                      child: Text('Numeric'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 30,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Numbers',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Expanded(flex: 30, child: Text('Decimal')),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 30,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Decimal',
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Ok'),
                      onPressed: () {
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ]),
            ),
          );
        });
  }
}
