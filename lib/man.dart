import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('myBox');
  bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Example',
      home: isLoggedIn ? const MyHomePage() : LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kirish')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration:
                  const InputDecoration(labelText: 'Foydalanuvchi nomi'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Parol'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text;
                final password = _passwordController.text;
                var box = Hive.box('myBox');
                // Foydalanuvchi nomini tekshirish
                if (box.get('username') == username) {
                  // Parolni tekshirish
                  if (box.get('password') == password) {
                    // Agar tekshiruv muvaffaqiyatli bo'lsa, isLoggedIn qiymatini true qilish
                    box.put('isLoggedIn', true);
                    // Avtomatik ravishda MyHomePage sahifasiga o'tish
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MyHomePage()));
                  }
                }
              },
              child: const Text('Kirish'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => RegisterPage()));
              },
              child: const Text('Ro\'yxatdan o\'tish'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ro\'yxatdan o\'tish')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration:
                  const InputDecoration(labelText: 'Foydalanuvchi nomi'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Parol'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text;
                final password = _passwordController.text;
                var box = Hive.box('myBox');
                box.put('username', username); // Foydalanuvchi nomini saqlash
                box.put('password', password); // Parolni saqlash
                Navigator.of(context).pop();
              },
              child: const Text('Ro\'yxatdan o\'tish'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUsername =
        Hive.box('myBox').get('username', defaultValue: '');

    return Scaffold(
      appBar: AppBar(title: Text('Xush kelibsiz! $currentUsername')),
      body: const Center(child: Text('')),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late String _currentUsername;
  late String _currentPassword;

  @override
  void initState() {
    super.initState();
    _currentUsername = Hive.box('myBox').get('username', defaultValue: '');
    _currentPassword = Hive.box('myBox').get('password', defaultValue: '');
    _usernameController.text = _currentUsername;
    _passwordController.text = _currentPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'username: $_currentUsername',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'password: $_currentPassword',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                final newUsername = _usernameController.text;
                final newPassword = _passwordController.text;
                var box = Hive.box('myBox');
                box.put('username', newUsername);
                box.put('password', newPassword);
                setState(() {
                  _currentUsername = newUsername;
                  _currentPassword = newPassword;
                });
              },
              child: const Text('Saqlash'),
            ),
            ElevatedButton(
              onPressed: () {
                Hive.box('myBox').delete('isLoggedIn');
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LoginPage()));
              },
              child: const Text('Chiqish'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
