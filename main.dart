import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MoodSyncApp());
}

class MoodSyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodSync',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MoodSelectionScreen(),
    );
  }
}

class MoodSelectionScreen extends StatelessWidget {

  final List<Map<String, String>> moods = [
    {"mood": "Happy", "emoji": "😊"},
    {"mood": "Sad", "emoji": "😞"},
    {"mood": "Motivated", "emoji": "⚡"},
    {"mood": "Relaxed", "emoji": "🧘"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Your Mood"),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
          )
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: moods.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuotesScreen(moods[index]["mood"]!),
                  ),
                );
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(moods[index]["emoji"]!,
                        style: TextStyle(fontSize: 40)),
                    SizedBox(height: 10),
                    Text(moods[index]["mood"]!,
                        style: TextStyle(fontSize: 18))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuotesScreen extends StatefulWidget {
  final String mood;

  QuotesScreen(this.mood);

  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {

  List quotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuotes();
  }

  fetchQuotes() async {
    final response =
    await http.get(Uri.parse("https://zenquotes.io/api/quotes"));

    if (response.statusCode == 200) {
      setState(() {
        quotes = json.decode(response.body);
        isLoading = false;
      });
    }
  }

  saveQuote(String quote) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList("favorites") ?? [];
    favs.add(quote);
    prefs.setStringList("favorites", favs);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Quote Saved")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.mood} Quotes"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (context, index) {

          String quote =
              quotes[index]["q"] + " - " + quotes[index]["a"];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(quotes[index]["q"]),
              subtitle: Text("- ${quotes[index]["a"]}"),
              trailing: IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: () {
                  saveQuote(quote);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList("favorites") ?? [];
    });
  }

  removeQuote(int index) async {
    final prefs = await SharedPreferences.getInstance();

    favorites.removeAt(index);

    prefs.setStringList("favorites", favorites);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorite Quotes"),
      ),
      body: favorites.isEmpty
          ? Center(child: Text("No favorites yet"))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(favorites[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  removeQuote(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

