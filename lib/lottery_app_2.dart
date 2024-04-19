import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottery_app/bloc/bloc.dart';
import 'package:lottery_app/model/lotter_model.dart';
import 'package:text_scroll/text_scroll.dart';

class LotteryApp2 extends StatefulWidget {
  final String label;
  final List<LotterModel> listofitems;
  final int num;
  final void Function(bool stop) onScrollstop;

  const LotteryApp2({
    super.key,
    required this.label,
    required this.listofitems,
    required this.num,
    required this.onScrollstop,
  });

  @override
  State<LotteryApp2> createState() => _LotteryApp2State();
}

class _LotteryApp2State extends State<LotteryApp2> {
  late Random random;
  late FixedExtentScrollController controller;
  late int duration;
  late Timer? scrollTimer;
  bool isScrolling = false;
  late int digitsLength;
  LotterModel winner = LotterModel(nama: '', number: '');
  late List<String> charList;
  late int currentValue;

  @override
  void initState() {
    super.initState();
    random = Random();
    digitsLength = widget.listofitems.length;
    duration = 60;
    controller = FixedExtentScrollController();
    currentValue = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startAutoScroll() {
    if (!isScrolling) {
      isScrolling = true;
      winner = LotterModel(nama: '', number: '');
      int counter = 0;
      scrollTimer = Timer.periodic(Duration(milliseconds: duration), (timer) {
        if (controller.hasClients) {
          controller.animateToItem(
            counter,
            duration: Duration(milliseconds: duration),
            curve: Curves.linear,
          );
          counter++;
          if (counter >= digitsLength) {
            counter = 0;
          }
        }
      });
      widget.onScrollstop(false);
    }
  }

  void stopAutoScroll() {
    if (isScrolling) {
      isScrolling = false;
      winner = widget.listofitems[random.nextInt(digitsLength)];
      charList = winner.number.split('');
      dev.log('Nama : ${winner.nama} <=> Num : ${winner.number}');
      Timer.periodic(Duration(milliseconds: duration), (timer) {
        int selectedIndex = widget.listofitems.indexOf(winner);
        scrollTimer?.cancel();
        controller
            .animateToItem(
          selectedIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.decelerate,
        )
            .then((value) {
          widget.onScrollstop(true);
          timer.cancel();
        });
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
          width: 400,
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
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.blue.shade800,
                      width: 1.0,
                    ),
                  ),
                  child: ListWheelScrollView.useDelegate(
                    controller: controller,
                    renderChildrenOutsideViewport: false,
                    itemExtent: 40,
                    useMagnifier: true,
                    magnification: 1.5,
                    diameterRatio: 1.5,
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: List.generate(
                        digitsLength,
                        (index) => SizedBox(
                          child: Card(
                            elevation: 2,
                            child: Center(
                              child: Text(
                                widget.listofitems[index].number,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    onSelectedItemChanged: (value) {
                      currentValue = value;
                    },
                  ),
                ),
              ),
              Center(
                child: TextScroll(
                  !isScrolling ? winner.nama : '',
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
