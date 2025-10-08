import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String quote = "Loading...";
  String author = "";

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    final url = Uri.parse("https://api.api-ninjas.com/v1/quotes");
    try {
      final response = await http.get(
        url,
        headers: {
          'X-Api-Key': 'jA774RYMHWSVHd+w2I0Eyg==3mYvpCdfzwHeWXCd',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          quote = data[0]['quote'];
          author = data[0]['author'];
        });
      } else {
        setState(() {
          quote = "Failed to load quote";
          author = "";
        });
      }
    } catch (e) {
      setState(() {
        quote = "Error: $e";
        author = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Random Quote"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "\"$quote\"",
                style: const TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                "- $author",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: fetchQuote,
                icon: const Icon(Icons.refresh),
                label: const Text("New Quote"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
