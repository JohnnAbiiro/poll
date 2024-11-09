/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Polling Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const PollingDashboard(),
    );
  }
}

class PollingDashboard extends StatefulWidget {
  const PollingDashboard({super.key});

  @override
  _PollingDashboardState createState() => _PollingDashboardState();
}

class _PollingDashboardState extends State<PollingDashboard> {
  final List<Map<String, dynamic>> questions = [
    {
      "question": "Do you support John Mahama's proposal for a 24-hour economy? ",
      "options": ["Yes, it will boost the economy and create jobs.", "No, it may lead to more challenges than benefits.", "Not sure."],
      "responses": [60, 30, 10],
    },
    {
      "question": "Should the government focus more on renewable energy?",
      "options": ["Yes, it’s crucial for sustainability.", "No, other priorities are more important.", "Neutral."],
      "responses": [70, 15, 15],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polling Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final questionData = questions[index];
            return PollingCard(questionData: questionData);
          },
        ),
      ),
    );
  }
}

class PollingCard extends StatefulWidget {
  final Map<String, dynamic> questionData;

  const PollingCard({required this.questionData, super.key});

  @override
  _PollingCardState createState() => _PollingCardState();
}

class _PollingCardState extends State<PollingCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: Text(widget.questionData['question']),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display each option with its label
                  ...List.generate(widget.questionData['options'].length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("${i + 1}️⃣ ${widget.questionData['options'][i]}")),
                          Text("${widget.questionData['responses'][i]}%"),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  // Display the bar chart
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        barGroups: widget.questionData['responses'].asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: Colors.deepPurple,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList()
                            .cast<BarChartGroupData>(), // Ensure casting here to List<BarChartGroupData>
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, _) {
                                return Text('${value.toInt()}%');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int index = value.toInt();
                                if (index >= 0 && index < widget.questionData['options'].length) {
                                  return Text("${index + 1}️⃣");
                                }
                                return const Text("");
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polling Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const PollingDashboard(),
    );
  }
}

class PollingDashboard extends StatefulWidget {
  const PollingDashboard({super.key});

  @override
  _PollingDashboardState createState() => _PollingDashboardState();
}

class _PollingDashboardState extends State<PollingDashboard> {
  List<Map<String, dynamic>> questions = [];
  int totalNames = 0;
  Map<String, int> voteReasonsCount = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url = Uri.parse('https://kologsoft.net/bots/data');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['data'] as List;

        setState(() {
          totalNames = results.length;
          questions = [
            {
              "question": "Do you support John Mahama's proposal for a 24-hour economy? 🤔",
              "options": ["Yes, it will boost the economy and create jobs.", "No, it may lead to more challenges than benefits.", "Not sure."],
              "responses": [
                results.where((entry) => entry['votereason'] == "1").length,
                results.where((entry) => entry['votereason'] == "2").length,
                results.where((entry) => entry['votereason'] == "3").length
              ],
              "names": results.map((entry) => entry['name']).toList(),
              "contacts": results.map((entry) => entry['contact']).toList(),
            },
          ];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polling Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Card with total names and toggle to show details
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ListTile(
                title: Text("Total Responses: $totalNames"),
                subtitle: Text("Tap to view names and contacts"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Names and Contacts"),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 200,
                        child: ListView.builder(
                          itemCount: questions[0]['names'].length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(questions[0]['names'][index]),
                              subtitle: Text(questions[0]['contacts'][index]),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Polling cards with bar charts for each question
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final questionData = questions[index];
                  return PollingCard(questionData: questionData);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PollingCard extends StatefulWidget {
  final Map<String, dynamic> questionData;

  const PollingCard({required this.questionData, super.key});

  @override
  _PollingCardState createState() => _PollingCardState();
}

class _PollingCardState extends State<PollingCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: Text(widget.questionData['question'] ?? 'No question available'),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ...List.generate(widget.questionData['options'].length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("${i + 1}️⃣ ${widget.questionData['options'][i]}")),
                          Text("${widget.questionData['responses'][i]}%"),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        // Generate bar groups and calculate each option's percentage
                        barGroups: (widget.questionData['responses'] as List<dynamic>)
                            .map((response) => response as int) // Explicitly cast each response to int
                            .toList()
                            .asMap()
                            .entries
                            .map<BarChartGroupData>((entry) {
                          int index = entry.key;
                          int responseValue = entry.value;

                          // Calculate total response sum to avoid type issues
                          int totalResponses = widget.questionData['responses']
                              .map((response) => response as int)
                              .fold(0, (sum, item) => sum + item);

                          // Calculate percentage for each option
                          double percentage = totalResponses > 0
                              ? (responseValue / totalResponses * 100)
                              : 0.0;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: percentage, // Setting height in terms of percentage
                                color: Colors.deepPurple,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        })
                            .toList(),
                        titlesData: FlTitlesData(
                          // Remove top titles by setting topTitles to showTitles: false
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, _) {
                                // Show percentage labels on the left, from 0% to 100%
                                return Text('${value.toInt()}%');
                              },
                              interval: 25, // Interval for 0%, 25%, 50%, 75%, and 100%
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int index = value.toInt();
                                if (index >= 0 && index < widget.questionData['options'].length) {
                                  return Text("${index + 1}️⃣");
                                }
                                return const Text("");
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        // Set y-axis range to 0-100 for percentage display
                        maxY: 100,
                        minY: 0,
                      ),
                    ),
                  ),




                ],
              ),
            ),
        ],
      ),
    );
  }
}
