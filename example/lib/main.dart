import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ppg_core/ppg_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _ppgCorePlugin = PpgCore();

  @override
  void initState() {
    super.initState();
    initializePpgCore();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initializePpgCore() async {
    // TBD Logic
    _ppgCorePlugin.initialize(
      // Only for iOS - default labels if custom channels is not defined
      iosLabels: ["Click me", "Show me"],
      onToken: (String tokenJSON) {
        // Upload this token to your server backend - you need this to use our API to send push notifications to this user
        // This is a JSON formatted string contains all necessery informations to our backend.
        log(tokenJSON);
      }
    );

    if (!mounted) return;

    _ppgCorePlugin.registerForNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const HomeScreen(),
        '/details': (context) => const DetailScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: ElevatedButton(
                child: const Text("Go to detail screen"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DetailScreen(),
                    ),
                  );
                })),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(child: Text("Detail screen")),
      ),
    );
  }
}
