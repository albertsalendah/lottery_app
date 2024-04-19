import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottery_app/bloc/bloc.dart';
import 'package:lottery_app/get_common_length.dart';
import 'package:lottery_app/model/lotter_model.dart';
import 'package:text_scroll/text_scroll.dart';

class LotteryApp extends StatefulWidget {
  final String label;
  final List<LotterModel> listofitems;
  final void Function(bool stop) onScrollstop;

  const LotteryApp({
    super.key,
    required this.label,
    required this.listofitems,
    required this.onScrollstop,
  });

  @override
  State<LotteryApp> createState() => _LotteryAppState();
}

class _LotteryAppState extends State<LotteryApp> {
  late Random random;
  late List<FixedExtentScrollController> controllers;
  late int duration;
  late List<Timer?> listscrollTimer;
  bool isScrolling = false;
  final List<String> numbers = List.generate(10, (index) => '$index');
  late int digitsLength;
  final _decelerationCurve =
      const Interval(0.0, 1.0, curve: Curves.easeInOutCubic);
  LotterModel winner = LotterModel(nama: '', number: '');
  late List<String> charList;
  bool stillScrolling = false;
  late List<int> currentValue;

  @override
  void initState() {
    super.initState();
    random = Random();
    duration = 60;
    digitsLength = getCommonLength(widget.listofitems);
    controllers =
        List.generate(digitsLength, (index) => FixedExtentScrollController());
    listscrollTimer = List.generate(digitsLength, (index) => null);
    currentValue = List.filled(digitsLength, 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startAutoScroll() {
    if (!isScrolling) {
      isScrolling = true;
      stillScrolling = true;
      winner = LotterModel(nama: '', number: '');
      List<int> counter = List.filled(digitsLength, 0);
      for (var i = 0; i < digitsLength; i++) {
        listscrollTimer[i] =
            Timer.periodic(Duration(milliseconds: duration), (timer) {
          for (var item in controllers) {
            if (item.hasClients) {
              item.animateToItem(
                counter[i],
                duration: Duration(milliseconds: duration),
                curve: Curves.linear,
              );
              counter[i]++;
              if (counter[i] >= numbers.length) {
                counter[i] = 0;
              }
            }
          }
        });
      }
      widget.onScrollstop(false);
    }
  }

  void stopAutoScroll() {
    if (isScrolling) {
      isScrolling = false;
      winner = widget.listofitems[random.nextInt(widget.listofitems.length)];
      charList = winner.number.split('');
      dev.log('Nama : ${winner.nama} <=> Num : ${winner.number}');
      Timer.periodic(Duration(milliseconds: duration), (timer) {
        int currentIndex = 0;
        for (var i = 0; i < digitsLength; i++) {
          if (controllers[i].hasClients) {
            if (currentIndex < charList.length) {
              String selectedItem = charList[currentIndex];
              int selectedIndex = numbers.indexOf(selectedItem);
              if (currentValue[i] != selectedIndex) {
                int step = currentValue[i] < selectedIndex ? 1 : -1;
                int targetValue = currentValue[i];
                listscrollTimer[i]?.cancel();
                Timer.periodic(Duration(milliseconds: duration), (stepTimer) {
                  if (targetValue != selectedIndex) {
                    targetValue += step;
                    controllers[i].animateToItem(
                      targetValue,
                      duration: Duration(milliseconds: duration),
                      curve: _decelerationCurve,
                    );
                  } else {
                    stepTimer.cancel();
                    currentIndex++;
                  }
                });
              } else {
                currentIndex++;
              }
            }
          }
        }
        if (currentIndex >= charList.length) {
          stillScrolling = false;
          widget.onScrollstop(true);
          setState(() {});
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LotteryBloc, LotteryState>(
      listener: (context, state) {
        if (state is Start) {
          startAutoScroll();
        } else if (state is Stop) {
          stopAutoScroll();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: digitsLength * 60,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Colors.blue.shade800,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: digitsLength * 54,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.blue.shade800,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      digitsLength,
                      (index) => SizedBox(
                        width: 50,
                        height: 200,
                        child: ListWheelScrollView.useDelegate(
                          controller: controllers[index],
                          renderChildrenOutsideViewport: false,
                          itemExtent: 50,
                          useMagnifier: true,
                          magnification: 1.5,
                          diameterRatio: 1.5,
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List.generate(
                              numbers.length,
                              (index) => SizedBox(
                                width: 32,
                                child: Card(
                                  elevation: 3,
                                  shape: const CircleBorder(),
                                  child: Center(
                                    child: Text(
                                      numbers[index],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onSelectedItemChanged: (value) {
                            currentValue[index] = value;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: TextScroll(
                  !stillScrolling ? winner.nama : '',
                  mode: TextScrollMode.endless,
                  velocity: const Velocity(pixelsPerSecond: Offset(150, 0)),
                  delayBefore: const Duration(milliseconds: 500),
                  pauseBetween: const Duration(milliseconds: 50),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  selectable: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
