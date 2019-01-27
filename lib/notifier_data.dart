import 'package:meta/meta.dart';

class NotifierData<T> {
  final bool hasData;
  final T data;

  NotifierData({
    @required this.hasData,
    @required this.data,
  }) : assert(hasData != null);

  @override
  String toString() {
    return "NotifierData(hasData = $hasData, data = $data)";
  }
}
