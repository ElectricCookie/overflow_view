import 'package:example/avatars.dart';
import 'package:example/menu.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overflow View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Overflow View Demo'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Avatars',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  AvatarsDemo(),
                  Divider(),
                  Text('Menu Bar', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  MenuDemo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
