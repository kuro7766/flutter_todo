import 'dart:async';

class NoActionTimer{
  int milliseconds;
  Function callback;
  Timer currentTimer;
  NoActionTimer(this.milliseconds, this.callback);

  void reset(){
    currentTimer?.cancel();
    currentTimer=Timer(Duration(milliseconds: milliseconds), (){
      callback();
    });
  }


}