import 'package:flutter/material.dart';
import 'package:notifier/notifier.dart';

void main() {
  runApp(
    NotifierProvider(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Notifier _notifier = NotifierProvider.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Notify'),
              onPressed: () {
                _notifier.notify('action', 'Data from 1st page.');
                print('Button Clicked');
              },
            ),
            ChildWidget(),
            RaisedButton(
              child: Text('Launch'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return NewPage(notifier: Notifier.of(context));
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChildWidget extends StatelessWidget {
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
}

class NewPage extends StatefulWidget {
  final Notifier notifier;

  const NewPage({
    Key key,
    @required this.notifier,
  }) : super(key: key);

  @override
  NewPageState createState() {
    return new NewPageState();
  }
}

class NewPageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.notifier.register<String>(
              'action',
              (data) {
                return Notifier.of(context).register<String>(
                  'action',
                  (data) {
                    return Text('${data.data}');
                  },
                );
              },
            ),
            RaisedButton(
              child: Text('Notify'),
              onPressed: () {
                widget.notifier.notify('action', 'Data from 2nd page.');
              },
            ),
          ],
        ),
      ),
    );
  }
}
