import 'package:flutter/material.dart';

import 'package:unelang_test/models/application.dart';

class LoadingApp extends StatefulWidget {
  @override
  _LoadingApp createState() => _LoadingApp();
}

class _LoadingApp extends State<LoadingApp> {

  @override
  void initState() {
    super.initState();
    ApplicationState.init().then((value) {
      Navigator.pushNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Logo(),
      ),
    );
  }
}


class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('UNELANG LOGO'));
  }
}