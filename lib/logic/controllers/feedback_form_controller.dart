import 'package:flutter/material.dart';
import '../../data/repos/feedback_repo.dart';

class FeedbackFormController extends ChangeNotifier {
  final FeedbackRepo _feedbackRepo;

  String? _selectedMeal;
  int _rating = 0;
  String _comment = '';
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isSuccess = false;

  FeedbackFormController({FeedbackRepo? feedbackRepo})
      : _feedbackRepo = feedbackRepo ?? FeedbackRepo();

  String? get selectedMeal => _selectedMeal;
  int get rating => _rating;
  String get comment => _comment;
  Set<String> get selectedTags => _selectedTags;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  bool get isValid => _rating > 0 && (_comment.trim().isNotEmpty || _selectedTags.isNotEmpty);

  void setMeal(String meal) {
    _selectedMeal = meal;
    notifyListeners();
  }

  void setRating(int newRating) {
    _rating = newRating.clamp(1, 5);
    notifyListeners();
  }

  void setComment(String value) {
    _comment = value;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void reset() {
    _selectedMeal = null;
    _rating = 0;
    _comment = '';
    _selectedTags.clear();
    _isSubmitting = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }

  Future<bool> submitFeedback({String? commentOverride, int? ratingOverride}) async {
    final effectiveRating = ratingOverride ?? _rating;
    final textComment = (commentOverride ?? _comment).trim();

    if (effectiveRating <= 0) {
      _errorMessage = 'Please provide a star rating.';
      notifyListeners();
      return false;
    }

    // Combine tags and comment if tags are present
    String fullMessage = textComment;
    if (_selectedTags.isNotEmpty) {
      final tagsStr = _selectedTags.map((t) => '#$t').join(' ');
      fullMessage = textComment.isNotEmpty ? '$tagsStr\n$textComment' : tagsStr;
    }

    if (fullMessage.isEmpty) {
      fullMessage = 'Rated $effectiveRating stars';
    }

    _isSubmitting = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _feedbackRepo.submitFeedback(
        message: fullMessage,
        rating: effectiveRating,
      );

      _isSuccess = true;
      reset();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
