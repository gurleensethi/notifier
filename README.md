# notifier

Update any widget, from anywhere at anytime.

## Getting Started

Inspired from `Broadcast Receiver` in Android.

Works for both `iOS` and `Android`.

##### Add the following dependency to your project's `pubspec.yaml`.

```yaml
notifier: <latest_version>
```

##### There are two methods that make the core of `Notifier`.
* `notify(action, data)` - Sending data for a certain action.
* `register(action, callback)` - Listening to data changes for a certain action.

##### Steps

* Add `NotifierProvider` at root of project's Widget tree. 

```dart
void main() {
  runApp(
    NotifierProvider(
      child: MyApp(),
    ),
  );
}
```

* Register a callback for a certain action in your Widget tree.

```dart
@override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Data from Notifier:'),
        Notifier.of(context).register<String>('action', (data) {
          return Text('${data.data}');
        }),
      ],
    );
  }
```

* From anywhere in your application, call the `notify` method.

```dart
@override
  Widget build(BuildContext context) {
    Notifier _notifier = NotifierProvider.of(context);

    return Scaffold(
      body: Center(
        RaisedButton(
          child: Text('Notify'),
          onPressed: () {
            _notifier.notify('action', 'Sending data from notfier!');
          },
        ),
      ),
    );
  }
```

#### Things to be aware of!
* If a callback is registered on an action with a specific data type `T`, then passing data with data type other than `T` in `notify` method will throw error.
