// import 'dart:async';
// import 'dart:developer' as dev;
// import 'dart:math';

// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

class LotteryBloc extends Bloc<LotteryEvent, LotteryState> {
  LotteryBloc() : super(InitialState()) {
    on<StartScrolling>(startScrolling);
    on<StopScrolling>(stopScrolling);
  }

  Future<void> startScrolling(
      StartScrolling event, Emitter<LotteryState> emit) async {
    emit(Start());
  }

  Future<void> stopScrolling(
      StopScrolling event, Emitter<LotteryState> emit) async {
    emit(Stop());
  }
}
