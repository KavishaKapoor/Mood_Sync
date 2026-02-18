import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MoodSyncApp());
}

class MoodSyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoodSync',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MoodSelectionScreen(),
    );
  }
}

class MoodSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> moods = [
    {"name": "Happy", "icon": Icons.sentiment_satisfied},
    {"name": "Sad", "icon": Icons.sentiment_dissatisfied},
    {"name": "Motivated", "icon": Icons.flash_on},
    {"name": "Relaxed", "icon": Icons.self_improvement},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Your Mood")),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: moods.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuoteScreen(mood: moods[index]["name"]),
                ),
              );
            },
            child: Card(
              elevation: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(moods[index]["icon"], size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    moods[index]["name"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  final String mood;

  QuoteScreen({required this.mood});

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  List quotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuotes();
  }

  Future<void> fetchQuotes() async {
    final response =
        await http.get(Uri.parse("https://zenquotes.io/api/quotes"));

    if (response.statusCode == 200) {
      List allQuotes = json.decode(response.body);

      // Simple mood-based filtering (basic keyword match)
      List filtered = allQuotes.where((quote) {
        String text = quote['q'].toString().toLowerCase();
        if (widget.mood == "Happy") {
          return text.contains("happy") || text.contains("joy");
        } else if (widget.mood == "Sad") {
          return text.contains("life") || text.contains("hope");
        } else if (widget.mood == "Motivated") {
          return text.contains("success") || text.contains("dream");
        } else if (widget.mood == "Relaxed") {
          return text.contains("peace") || text.contains("calm");
        }
        return true;
      }).toList();

      setState(() {
        quotes = filtered.isEmpty ? allQuotes : filtered;
        isLoading = false;
      });
    } else {
      throw Exception("Failed to load quotes");
    }
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
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      quotes[index]['q'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("- ${quotes[index]['a']}"),
                  ),
                );
              },
            ),
    );
  }
}
