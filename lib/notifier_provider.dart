import 'package:flutter/material.dart';
import 'package:notifier/notifier.dart';
import 'package:notifier/notifier_impl.dart';

class NotifierProvider extends InheritedWidget {
  final Notifier _notifier = NotifierImpl();

  NotifierProvider({Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Notifier of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(NotifierProvider)
            as NotifierProvider)
        ._notifier;
  }
}
