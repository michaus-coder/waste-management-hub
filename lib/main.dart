import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste Management Hub Experiment',
      initialRoute: '/',
      routes: {
        '/home': (context) => const Home(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Waste Management Hub Experiment'),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Login Page',
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                  controller: usernameController,
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 24),
                Builder(builder: (context) {
                  return ElevatedButton(
                    child: const Text('Login'),
                    onPressed: () {
                      if (usernameController.text == 'admin' &&
                          passwordController.text == 'admin') {
                        Navigator.pushReplacementNamed(
                          context,
                          '/home',
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Login Failed'),
                            content: const Text('Invalid username or password'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
