part of 'bloc.dart';

abstract class LotteryState {
  String get item;
}

class InitialState extends LotteryState {
  @override
  String get item => '';
}

class Start extends LotteryState {
  @override
  String get item => '';
  Start();
}

class Stop extends LotteryState {
  Stop();

  @override
  String get item => '';
}
