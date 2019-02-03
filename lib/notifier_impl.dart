import 'package:flutter/material.dart';
import 'package:notifier/main_notifier.dart';
import 'package:notifier/notifier_data.dart';
import 'package:notifier/notifier_provider.dart';
import 'dart:async';
import 'package:synchronized/synchronized.dart';

/// Implementation of [Notifier].
///
/// Uses [Stream] as primary way to communicate broadcasts.
/// Callbacks are wrapped inside a [StreamBuilder] which is returned from [build]
/// method of a [StatefulWidget]. Whenever [notify] is called, the stream
/// is notified for changes, so all the [StreamBuilder]'s connected to that stream
/// are rebuilt thus fetching new data.
///
/// Every operation is added to a queue of work using [Lock] from
/// 'synchronized' package.
class NotifierImpl implements Notifier {
  // Main [Lock] used for every operation
  final _lock = Lock();

  /// Mapping of current number of callbacks registered with a certain action.
  Map<String, int> _registerCount = {};

  /// Mapping of current data for a certain action;
  Map<String, dynamic> _actionDataMappings = {};

  /// Mapping of action and the stream opened for the same.
  Map<String, StreamController<dynamic>> _actionStreamMappings = {};

  static Notifier of(BuildContext context) {
    return NotifierProvider.of(context);
  }

  @override
  void notify<T>(String action, T data) {
    _lock.synchronized(() {
      // Update the action-data mappings.
      _actionDataMappings[action] =
          NotifierData(hasData: data != null, data: data);

      // Notify the stream that data has been changed.
      _actionStreamMappings[action]?.add(null);
    });
  }

  @override
  Widget register<T>(String action, Widget Function(NotifierData<T>) callback) {
    _checkAndCreateStream(action);

    return _NotifierWidget(
      action: action,
      callback: callback,
      notifier: this,
    );
  }

  @override
  void dispose() {
    _actionStreamMappings.values.forEach((stream) => stream.close());
  }

  /// Checks if there a stream for a particular [action], if not then a new
  /// [Stream] is created for that action and default data is added to it;
  ///
  /// This functions helps to prevent adding [Stream] for actions that don't
  /// have any callbacks.
  void _checkAndCreateStream(String action) {
    if (!_actionStreamMappings.containsKey(action)) {
      _actionStreamMappings[action] = StreamController.broadcast();
      _actionDataMappings[action] = NotifierData(hasData: false, data: null);
    }
  }

  /// Increment the current count of callbacks registered for the stream
  /// with [action].
  void _incrementRegisterCount(String action) {
    _lock.synchronized(() {
      _registerCount[action] = (_registerCount[action] ?? 0) + 1;
    });
  }

  /// Decrement the current count of callbacks registered for the stream
  /// with [action].
  ///
  /// Check if it was the last callback. If so then close and remove the stream
  /// from mappings.
  void _decrementRegisterCount(String action) {
    _lock.synchronized(() {
      _registerCount[action] = (_registerCount[action] ?? 0) - 1;

      if (_registerCount[action] <= 0) {
        _actionStreamMappings[action]?.close();

        _registerCount.remove(action);
        _actionStreamMappings.remove(action);
        _actionDataMappings.remove(action);
      }
    });
  }
}

/// Widget that wraps the callback into a [StreamBuilder] for a particular
/// action.
class _NotifierWidget extends StatefulWidget {
  final String action;
  final dynamic callback;
  final NotifierImpl notifier;

  const _NotifierWidget({
    Key key,
    @required this.action,
    @required this.callback,
    @required this.notifier,
  }) : super(key: key);

  @override
  _NotifierWidgetState createState() => _NotifierWidgetState();
}

class _NotifierWidgetState extends State<_NotifierWidget> {
  @override
  void initState() {
    widget.notifier._incrementRegisterCount(widget.action);
    super.initState();
  }

  @override
  void dispose() {
    widget.notifier._decrementRegisterCount(widget.action);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.notifier._actionStreamMappings[widget.action].stream
          .asBroadcastStream(),
      builder: (context, _) {
        final data = widget.notifier._actionDataMappings[widget.action];
        return widget.callback(data);
      },
    );
  }
}
