import 'dart:io';
import 'dart:math';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:lottery_app/bloc/bloc.dart';
import 'package:lottery_app/lottery_app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lottery_app/lottery_app_2.dart';
import 'package:lottery_app/model/lotter_model.dart';

class StartLottery extends StatefulWidget {
  const StartLottery({super.key});

  @override
  State<StartLottery> createState() => _StartLotteryState();
}

class _StartLotteryState extends State<StartLottery> {
  List<String> items = [];
  int numberOfInstance = 1;
  List<ListLotterModel> listLottery = [];
  bool startORstop = true;
  bool isFullscreen = false;
  bool perDigit = true;

  @override
  void initState() {
    super.initState();
    items = generateRandomNumbers(10);
    perDigit = kIsWeb ? false : true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> generateRandomNumbers(int count) {
    final random = Random();
    return List<String>.generate(count, (_) {
      final randomNumber = random.nextInt(900000000) + 100000000;
      return randomNumber.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Visibility(
            visible: !kIsWeb,
            child: Switch(
              value: perDigit,
              onChanged: (value) {
                setState(() {
                  perDigit = !perDigit;
                });
              },
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {});
              _pickAndReadExcel().then((value) {
                setState(() {});
              });
            },
            icon: const Icon(Icons.folder),
          ),
          IconButton(
            tooltip: !isFullscreen ? 'Fullscreen' : 'Keluar Fullscreen',
            onPressed: () {
              isFullscreen = !isFullscreen;
              FullScreenWindow.setFullScreen(isFullscreen);

              setState(() {});
            },
            icon: Icon(!isFullscreen
                ? Icons.fullscreen_rounded
                : Icons.fullscreen_exit_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: startORstop ? 'Start' : 'Stop',
        onPressed: listLottery.isNotEmpty
            ? () async {
                if (startORstop) {
                  if (context.mounted) {
                    context.read<LotteryBloc>().add(StartScrolling());
                  }
                } else {
                  context.read<LotteryBloc>().add(StopScrolling());
                }
                startORstop = !startORstop;
                setState(() {});
              }
            : null,
        child: Icon(startORstop ? Icons.play_arrow_rounded : Icons.pause),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Wrap(
            verticalDirection: VerticalDirection.down,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: listLottery.isNotEmpty
                ? List.generate(
                    listLottery.length,
                    (index) => perDigit
                        ? LotteryApp(
                            label: listLottery[index].namaSheet,
                            listofitems: listLottery[index].listLottery,
                            onScrollstop: (stop) {
                              if (stop) {}
                            },
                          )
                        : LotteryApp2(
                            label: listLottery[index].namaSheet,
                            listofitems: listLottery[index].listLottery,
                            num: listLottery.length,
                            onScrollstop: (stop) {
                              if (stop) {}
                            },
                          ),
                  )
                : [],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndReadExcel() async {
    startORstop = true;
    listLottery.clear();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );
    List<Excel?> listExcel = [];
    if (kIsWeb) {
      if (result != null) {
        List<PlatformFile> files = result.files;
        for (var file in files) {
          // dev.log("Nama File : ${file.name}");
          var bytes = file.bytes!.toList();
          var excel = Excel.decodeBytes(bytes);
          listExcel.add(excel);
        }
      }
    } else {
      if (result != null) {
        List<File> files =
            result.paths.map((path) => File(path ?? '')).toList();
        for (var file in files) {
          var bytes = file.readAsBytesSync();
          var excel = Excel.decodeBytes(bytes);
          listExcel.add(excel);
        }
      }
    }

    for (var excelFile in listExcel) {
      if (excelFile != null) {
        for (var table in excelFile.tables.keys) {
          List<LotterModel> list = [];
          for (var row in excelFile.tables[table]!.rows) {
            if (row.every((cell) => cell == null || cell.value == null)) {
              continue; // Skip empty or entirely null rows
            }

            if (row.length >= 2) {
              // Assuming each row has at least two columns
              var number = row[0]?.value ?? '';
              var nama = row[1]?.value ?? '';
              list.add(LotterModel(
                  number: number.toString(), nama: nama.toString()));
            }
          }
          listLottery.add(ListLotterModel(namaSheet: table, listLottery: list));
        }
      }
    }
  }
}
