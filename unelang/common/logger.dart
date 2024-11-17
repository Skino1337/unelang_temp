class Logger {
  static void info (String data) {
    final currentTime = DateTime.now();

    String currentTimeFormated = '${currentTime.hour}';
    currentTimeFormated += ':${currentTime.minute}';
    currentTimeFormated += ':${currentTime.second}';
    currentTimeFormated += '.${currentTime.millisecond}';

    print('[$currentTimeFormated] $data');
  }
}