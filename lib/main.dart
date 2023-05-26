import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/setup/firestore.dart';
import 'package:namer_app/setup/root.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/setup/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState()..init(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(primary: Color.fromARGB(255, 4, 32, 25)),
        ),
        home: RootPage(
          auth: Auth(),
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  WordPair current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late String userId;
  List<WordPair> favorites = [];

  Future<void> init() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      userId = user.uid;
      favorites = await firestoreService.getFavorites(userId);
    }
  }

  void toggleFavorite() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      userId = user.uid;
      print('$userId');
      if (favorites.contains(current)) {
        favorites.remove(current);
        await firestoreService.removeFavorite(userId, current);
      } else {
        favorites.add(current);
        await firestoreService.addFavorite(userId, current);
      }
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.auth, required this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  void signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(
          onLogoutPressed: widget.signOut,
        );
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(appState.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        var favorites = List<String>.from(data['favorites'] ?? []);

        if (favorites.isEmpty) {
          return Center(
            child: Text('No favorites yet.'),
          );
        }

        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'You have ${favorites.length} favorites:',
              ),
            ),
            for (var pair in favorites)
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text(pair),
              ),
          ],
        );
      },
    );
  }
}

class GeneratorPage extends StatelessWidget {
  GeneratorPage({required this.onLogoutPressed});
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: onLogoutPressed,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.headline5!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asCamelCase,
        ),
      ),
    );
  }
}
