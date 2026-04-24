class Question {
  final String id;
  final String category;
  final String? difficulty;
  final String question;
  final List<String> options;
  final int correctIndex;
  final List<String> explanations;

  const Question({
    required this.id,
    required this.category,
    this.difficulty,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanations,
  });

  String get randomExplanation {
    if (explanations.isEmpty) return 'Pas d\'explication disponible';
    return explanations[DateTime.now().millisecond % explanations.length];
  }
}

class Category {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int questionCount;
  final String color;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.questionCount,
    required this.color,
  });
}

class QuizResult {
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final Duration duration;
  final List<QuestionAnswer> answers;

  QuizResult({
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.duration,
    required this.answers,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
  String get grade {
    if (percentage >= 90) return 'Excellente';
    if (percentage >= 80) return 'Très bien';
    if (percentage >= 70) return 'Bien';
    if (percentage >= 60) return 'Assez bien';
    return 'À revoir';
  }
}

class QuestionAnswer {
  final Question question;
  final int selectedIndex;
  final bool isCorrect;
  final DateTime answeredAt;
  final bool isTimeout;

  QuestionAnswer({
    required this.question,
    required this.selectedIndex,
    required this.isCorrect,
    required this.answeredAt,
    this.isTimeout = false,
  });
}
