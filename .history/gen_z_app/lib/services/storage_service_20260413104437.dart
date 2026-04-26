import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

class StorageService {
  static const String _historyKey = 'quiz_history';
  static const String _themeKey = 'app_theme';
  
  static Future<void> saveQuizResult(QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    final historyItem = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: result.category,
      score: result.score,
      totalQuestions: result.totalQuestions,
      correctAnswers: result.correctAnswers,
      percentage: result.percentage,
      grade: result.grade,
      duration: result.duration,
      date: DateTime.now(),
      answers: result.answers,
    );
    
    history.insert(0, historyItem);
    
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }
  
  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((e) => HistoryItem.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
  
  static Future<void> saveTheme(String themeColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeColor);
  }
  
  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'default';
  }
}

class HistoryItem {
  final String id;
  final String category;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final double percentage;
  final String grade;
  final Duration duration;
  final DateTime date;
  final List<QuestionAnswer> answers;

  HistoryItem({
    required this.id,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.grade,
    required this.duration,
    required this.date,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'percentage': percentage,
      'grade': grade,
      'duration': duration.inSeconds,
      'date': date.toIso8601String(),
      'answers': answers.map((a) => {
        'questionId': a.question.id,
        'selectedIndex': a.selectedIndex,
        'isCorrect': a.isCorrect,
      }).toList(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      category: json['category'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      percentage: json['percentage'],
      grade: json['grade'],
      duration: Duration(seconds: json['duration']),
      date: DateTime.parse(json['date']),
      answers: [],
    );
  }
}
