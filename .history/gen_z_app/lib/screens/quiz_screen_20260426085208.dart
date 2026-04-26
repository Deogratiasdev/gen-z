import 'package:flutter/material.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/typewriter_text.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Category category;
  final List<Question> questions;
  final String? difficulty;

  const QuizScreen({
    super.key,
    required this.category,
    required this.questions,
    this.difficulty,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _ShuffledQuestion {
  final Question original;
  final List<String> shuffledOptions;
  final int newCorrectIndex;

  _ShuffledQuestion({
    required this.original,
    required this.shuffledOptions,
    required this.newCorrectIndex,
  });

  // Getters pour accéder facilement aux propriétés
  String get question => original.question;
  String get id => original.id;
  String get category => original.category;
  List<String> get options => shuffledOptions;
  int get correctIndex => newCorrectIndex;
  String get randomExplanation => original.randomExplanation;
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _isTimeout = false;
  int _score = 0;
  int _correctCount = 0;
  late DateTime _startTime;
  late List<QuestionAnswer> _answers;
  late List<_ShuffledQuestion> _shuffledQuestions;

  // Timer
  static const int _timeLimitSeconds = 15;
  int _remainingSeconds = _timeLimitSeconds;
  late AnimationController _timerController;

  late AnimationController _feedbackController;
  late Animation<double> _feedbackScale;

  // Scroll controller
  late ScrollController _scrollController;

  _ShuffledQuestion get _currentQuestion => _shuffledQuestions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == widget.questions.length - 1;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _answers = [];
    _shuffledQuestions = _shuffleAllQuestions();
    _scrollController = ScrollController();
    _initAnimations();
    _initTimer();
  }

  List<_ShuffledQuestion> _shuffleAllQuestions() {
    return widget.questions.map((q) {
      // Créer une liste d'indices mélangés
      final indices = List<int>.generate(q.options.length, (i) => i);
      indices.shuffle();

      // Créer les options mélangées
      final shuffledOptions = indices.map((i) => q.options[i]).toList();

      // Trouver le nouvel index de la bonne réponse
      final newCorrectIndex = indices.indexOf(q.correctIndex);

      return _ShuffledQuestion(
        original: q,
        shuffledOptions: shuffledOptions,
        newCorrectIndex: newCorrectIndex,
      );
    }).toList();
  }

  void _initTimer() {
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _timeLimitSeconds),
    );
    _timerController.addListener(() {
      final elapsed = _timerController.value * _timeLimitSeconds;
      setState(() {
        _remainingSeconds = (_timeLimitSeconds - elapsed).ceil();
      });
    });
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleTimeout();
      }
    });
    _timerController.forward();
  }

  void _handleTimeout() {
    if (_showFeedback) return;

    setState(() {
      _isTimeout = true;
      _showFeedback = true;
      _isCorrect = false;
    });

    _feedbackController.forward();

    // Scroll vers le bas après un court délai pour laisser le temps à l'animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });

    _answers.add(
      QuestionAnswer(
        question: _currentQuestion.original,
        selectedIndex: -1,
        isCorrect: false,
        answeredAt: DateTime.now(),
        isTimeout: true,
      ),
    );
  }

  void _resetTimer() {
    _timerController.reset();
    _timerController.forward();
    setState(() => _remainingSeconds = _timeLimitSeconds);
  }

  void _initAnimations() {
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _feedbackScale = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );
  }

  void _selectAnswer(int index) {
    if (_showFeedback) return;

    _timerController.stop();

    setState(() {
      _selectedAnswer = index;
      _isCorrect = index == _currentQuestion.correctIndex;
      _showFeedback = true;
      _isTimeout = false;
    });

    if (_isCorrect) {
      _score += 10;
      _correctCount++;
    } else {
      // Scroll vers le bas en cas de mauvaise réponse
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    }

    _feedbackController.forward();

    _answers.add(
      QuestionAnswer(
        question: _currentQuestion.original,
        selectedIndex: index,
        isCorrect: _isCorrect,
        answeredAt: DateTime.now(),
        isTimeout: false,
      ),
    );
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _finishQuiz();
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showFeedback = false;
        _isCorrect = false;
        _isTimeout = false;
      });
      _feedbackController.reset();
      _resetTimer();
    }
  }

  void _finishQuiz() {
    final duration = DateTime.now().difference(_startTime);
    final result = QuizResult(
      category: widget.category.name,
      totalQuestions: widget.questions.length,
      correctAnswers: _correctCount,
      score: _score,
      duration: duration,
      answers: _answers,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _timerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildProgressBar(progress),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildQuestionNumber(),
                    const SizedBox(height: 12),
                    _buildQuestion(),
                    const SizedBox(height: 16),
                    _buildOptions(),
                    if (_showFeedback) ...[
                      const SizedBox(height: 12),
                      _buildFeedback(),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            if (_showFeedback) _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppTheme.textPrimary),
            style: IconButton.styleFrom(backgroundColor: AppTheme.surface),
          ),
          const Spacer(),
          // Badge de difficulté
          if (widget.difficulty != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDifficultyColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getDifficultyLabel(),
                style: TextStyle(
                  color: _getDifficultyColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          if (widget.difficulty != null) const SizedBox(width: 12),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _remainingSeconds <= 5
                  ? AppTheme.incorrect.withValues(alpha: 0.2)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: _remainingSeconds <= 5
                      ? AppTheme.incorrect
                      : AppTheme.warning,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_remainingSeconds}s',
                  style: TextStyle(
                    color: _remainingSeconds <= 5
                        ? AppTheme.incorrect
                        : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: AppTheme.accentPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accentPrimary, AppTheme.accentTertiary],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionNumber() {
    return Row(
      children: [
        Text(
          'Question ${_currentIndex + 1}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          ' /${widget.questions.length}',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Question ${_currentIndex + 1}/${widget.questions.length}',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentQuestion.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: List.generate(
        _currentQuestion.options.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _OptionButton(
            option: _currentQuestion.options[index],
            index: index,
            isSelected: _selectedAnswer == index,
            isCorrect: _currentQuestion.correctIndex == index,
            showFeedback: _showFeedback,
            onTap: () => _selectAnswer(index),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    // En cas de timeout : on ne montre pas la réponse ni l'explication
    if (_isTimeout) {
      return ScaleTransition(
        scale: _feedbackScale,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.timer_off,
                      color: AppTheme.warning,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Temps écoulé !',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous n\'avez pas répondu à temps. Cette question compte pour 0 point.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Cas normal (bonne ou mauvaise réponse)
    return ScaleTransition(
      scale: _feedbackScale,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isCorrect
              ? AppTheme.correct.withOpacity(0.08)
              : AppTheme.incorrect.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? AppTheme.correct.withOpacity(0.2)
                        : AppTheme.incorrect.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _isCorrect ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect ? AppTheme.correct : AppTheme.incorrect,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _isCorrect ? 'Bonne réponse !' : 'Mauvaise réponse',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _isCorrect ? AppTheme.correct : AppTheme.incorrect,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Explication :',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            AnimatedExplanation(
              text: _currentQuestion.randomExplanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
            if (!_isCorrect) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.correct.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, color: AppTheme.correct, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Réponse correcte : ${_currentQuestion.options[_currentQuestion.correctIndex]}',
                        style: const TextStyle(
                          color: AppTheme.correct,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case 'facile':
        return Colors.green;
      case 'moyen':
        return Colors.orange;
      case 'difficile':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getDifficultyLabel() {
    switch (widget.difficulty) {
      case 'facile':
        return '🟢 Facile';
      case 'moyen':
        return '🟡 Moyen';
      case 'difficile':
        return '🔴 Difficile';
      default:
        return 'QCM';
    }
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _nextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            _isLastQuestion ? 'Résultats' : 'Continuer',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool showFeedback;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.showFeedback,
    required this.onTap,
  });

  Color get _backgroundColor {
    if (!showFeedback) {
      return isSelected
          ? AppTheme.accentPrimary.withOpacity(0.08)
          : AppTheme.surface;
    }
    if (isCorrect) return AppTheme.correct.withOpacity(0.08);
    if (isSelected && !isCorrect) return AppTheme.incorrect.withOpacity(0.08);
    return AppTheme.surface.withOpacity(0.3);
  }

  Color get _textColor {
    if (!showFeedback) {
      return isSelected ? AppTheme.textPrimary : AppTheme.textPrimary;
    }
    if (isCorrect) return AppTheme.correct;
    if (isSelected && !isCorrect) return AppTheme.incorrect;
    return AppTheme.textMuted;
  }

  Widget? get _trailingIcon {
    if (!showFeedback) return null;
    if (isCorrect) {
      return const Icon(Icons.check_circle, color: AppTheme.correct, size: 24);
    }
    if (isSelected && !isCorrect) {
      return const Icon(Icons.cancel, color: AppTheme.incorrect, size: 24);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showFeedback ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected || showFeedback)
              BoxShadow(
                color:
                    (isCorrect
                            ? AppTheme.correct
                            : isSelected && !isCorrect
                            ? AppTheme.incorrect
                            : AppTheme.accentPrimary)
                        .withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Lettre de l'option améliorée
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _backgroundColor == AppTheme.surface
                    ? AppTheme.surfaceLight
                    : _backgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                option,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (_trailingIcon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isCorrect ? AppTheme.correct : AppTheme.incorrect)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _trailingIcon!,
              ),
          ],
        ),
      ),
    );
  }
}
