import 'package:flutter/material.dart';
import 'package:notifier/notifier_data.dart';
import 'package:notifier/notifier_provider.dart';

abstract class Notifier {
  /// Send [data] as broadcasts to listeners registered with [action].
  void notify<T>(String action, T data);

  /// Register a new callback on [action].
  Widget register<T>(String action, Widget Function(NotifierData<T>) callback);

  /// Dispose any resources that are open.
  void dispose();

  static Notifier of(BuildContext context) {
    return NotifierProvider.of(context);
  }
}
