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
      debugShowCheckedModeBanner: false,
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    setState(() {
      isLoading = true;
    });

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
        title: const Text('Polling Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[900],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchQuestions, // Call fetchQuestions on pull-to-refresh
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                child: ListTile(
                  title: Text("Total Responses: $totalNames",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                  subtitle: const Text("Tap to view names and contacts",
                    style: TextStyle(
                        color: Colors.black54
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Names and Contacts", style: TextStyle(fontSize: 18)),
                        content: SizedBox(
                          width: double.maxFinite,
                          height: 200,
                          child: ListView.builder(
                            itemCount: questions[0]['names'].length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(questions[0]['names'][index], style: const TextStyle(color: Colors.black)),
                                    subtitle: Text(questions[0]['contacts'][index], style: const TextStyle(color: Colors.black54)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                                    child: Divider(color: Colors.grey[300]),
                                  ),
                                ],
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
    int totalResponses = (widget.questionData['responses'] as List<int>).fold(0, (sum, item) => sum + item);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
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
                    int responseCount = widget.questionData['responses'][i];
                    double percentage = totalResponses > 0 ? (responseCount / totalResponses) * 100 : 0.0;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text("${i + 1}️⃣   ${widget.questionData['options'][i]}")),
                            Text("${percentage.toStringAsFixed(1)}%"),
                          ],
                        ),
                        Divider(color: Colors.grey[300]),
                      ],
                    );
                  }),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        barGroups: widget.questionData['responses']
                            .asMap()
                            .entries
                            .map<BarChartGroupData>((entry) {  // Specify <BarChartGroupData> here
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
                        }).toList(),  // Convert to a List<BarChartGroupData>
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
                    )

                    // BarChart(
                    //   BarChartData(
                    //     barGroups: widget.questionData['responses'].asMap().entries.map((entry) {
                    //       return BarChartGroupData(
                    //         x: entry.key,
                    //         barRods: [
                    //           BarChartRodData(
                    //             toY: entry.value.toDouble(),
                    //             color: Colors.deepPurple,
                    //             width: 16,
                    //             borderRadius: BorderRadius.circular(4),
                    //           ),
                    //         ],
                    //       );
                    //     }).toList(),
                    //     titlesData: FlTitlesData(
                    //       leftTitles: AxisTitles(
                    //         sideTitles: SideTitles(
                    //           showTitles: true,
                    //           reservedSize: 30,
                    //           getTitlesWidget: (value, _) {
                    //             return Text('${value.toInt()}%');
                    //           },
                    //         ),
                    //       ),
                    //       bottomTitles: AxisTitles(
                    //         sideTitles: SideTitles(
                    //           showTitles: true,
                    //           getTitlesWidget: (value, _) {
                    //             int index = value.toInt();
                    //             if (index >= 0 && index < widget.questionData['options'].length) {
                    //               return Text("${index + 1}️⃣");
                    //             }
                    //             return const Text("");
                    //           },
                    //         ),
                    //       ),
                    //     ),
                    //     borderData: FlBorderData(show: false),
                    //   ),
                    // ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
