import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class MLPredictionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Model parameters (trained weights)
  late List<List<double>> _weights;
  late List<double> _bias;
  bool _isModelInitialized = false;
  
  // Feature extraction parameters
  static const int LOOKBACK_DAYS = 14;
  static const int TIME_SLOTS_PER_DAY = 24;
  static const int FEATURE_COUNT = 15;
  
  MLPredictionService() {
    _initializeModel();
  }
  
  void _initializeModel() {
    // Initialize with pre-trained weights (in a real scenario, these would be loaded from a trained model)
    // Features: [hour_of_day, day_of_week, medication_count, task_count, avg_completion_rate, 
    //           time_since_last_missed, stress_level, sleep_quality, weather_factor,
    //           social_interaction, routine_disruption, medication_complexity, age_factor,
    //           cognitive_load, historical_pattern_score]
    
    _weights = [
      [0.15, -0.23, 0.31, 0.18, -0.45, 0.22, 0.33, -0.19, 0.12, -0.17, 0.28, 0.35, 0.21, 0.19, -0.41],
      [0.21, 0.17, -0.28, 0.33, 0.52, -0.31, -0.24, 0.37, -0.15, 0.23, -0.19, -0.33, 0.29, -0.22, 0.48],
      [-0.19, 0.31, 0.22, -0.15, -0.38, 0.17, 0.26, -0.21, 0.33, -0.18, 0.24, 0.19, -0.27, 0.35, -0.29]
    ];
    
    _bias = [0.1, -0.05, 0.08];
    _isModelInitialized = true;
  }
  
  Future<PredictionResult> predictForgetfulness(String userId, {
    required String taskType, // 'medication' or 'routine'
    required DateTime targetTime,
    required String itemName,
  }) async {
    if (!_isModelInitialized) {
      throw Exception('ML model not initialized');
    }
    
    try {
      // Extract features
      final features = await _extractFeatures(userId, taskType, targetTime, itemName);
      
      // Make prediction
      final prediction = _predict(features);
      
      // Convert to risk scores
      final riskScores = _calculateRiskScores(prediction);
      
      // Generate recommendations
      final recommendations = _generateRecommendations(riskScores, taskType, targetTime);
      
      return PredictionResult(
        userId: userId,
        taskType: taskType,
        itemName: itemName,
        targetTime: targetTime,
        forgetfulnessRisk: riskScores['forgetfulness']!,
        delayRisk: riskScores['delay']!,
        skipRisk: riskScores['skip']!,
        confidence: riskScores['confidence']!,
        recommendations: recommendations,
        predictionTime: DateTime.now(),
      );
    } catch (e) {
      print('Error in ML prediction: $e');
      // Return default medium risk if prediction fails
      return PredictionResult(
        userId: userId,
        taskType: taskType,
        itemName: itemName,
        targetTime: targetTime,
        forgetfulnessRisk: 0.5,
        delayRisk: 0.5,
        skipRisk: 0.3,
        confidence: 0.3,
        recommendations: ['Unable to generate prediction - using default reminders'],
        predictionTime: DateTime.now(),
      );
    }
  }
  
  Future<List<double>> _extractFeatures(String userId, String taskType, DateTime targetTime, String itemName) async {
    final now = DateTime.now();
    final features = List<double>.filled(FEATURE_COUNT, 0.0);
    
    // Time-based features
    features[0] = targetTime.hour / 24.0; // Hour of day (normalized)
    features[1] = targetTime.weekday / 7.0; // Day of week (normalized)
    
    // Historical data
    final historicalData = await _getHistoricalData(userId, taskType, now.subtract(Duration(days: LOOKBACK_DAYS)));
    
    // Task complexity features
    features[2] = await _getMedicationCount(userId); // Number of medications
    features[3] = await _getTaskCount(userId); // Number of daily tasks
    
    // Performance features
    features[4] = _calculateCompletionRate(historicalData); // Average completion rate
    features[5] = _getTimeSinceLastMissed(historicalData, now); // Time since last missed (normalized)
    
    // Contextual features (simulated - in real app, these would come from sensors/user input)
    features[6] = _estimateStressLevel(historicalData); // Stress level
    features[7] = _estimateSleepQuality(targetTime); // Sleep quality estimate
    features[8] = _getWeatherFactor(targetTime); // Weather impact
    features[9] = _estimateSocialInteraction(targetTime); // Social interaction level
    features[10] = _detectRoutineDisruption(historicalData, targetTime); // Routine disruption
    
    // Medication/task specific features
    features[11] = await _getMedicationComplexity(userId, itemName); // Medication complexity
    features[12] = 0.7; // Age factor (normalized, would come from user profile)
    features[13] = _calculateCognitiveLoad(features[2], features[3]); // Cognitive load
    features[14] = _calculateHistoricalPatternScore(historicalData, targetTime); // Historical pattern
    
    return features;
  }
  
  List<double> _predict(List<double> features) {
    // Simple neural network prediction (forward pass)
    final hidden = <double>[];
    
    // Matrix multiplication: weights * features + bias
    for (int i = 0; i < _weights.length; i++) {
      double sum = 0.0;
      for (int j = 0; j < features.length; j++) {
        sum += _weights[i][j] * features[j];
      }
      hidden.add(sum + _bias[i]);
    }
    
    // Apply softmax activation
    final expValues = hidden.map((x) => exp(x)).toList();
    final sumExp = expValues.reduce((a, b) => a + b);
    final probabilities = expValues.map((x) => x / sumExp).toList();
    
    return probabilities;
  }
  
  Map<String, double> _calculateRiskScores(List<double> prediction) {
    // Convert model output to interpretable risk scores
    final scores = prediction;
    
    return {
      'forgetfulness': scores[0].clamp(0.0, 1.0), // Probability of completely forgetting
      'delay': scores[1].clamp(0.0, 1.0), // Probability of significant delay
      'skip': scores[2].clamp(0.0, 1.0), // Probability of intentional skip
      'confidence': _calculateConfidence(scores), // Model confidence
    };
  }
  
  double _calculateConfidence(List<double> scores) {
    // Calculate confidence based on prediction entropy
    final entropy = -scores.map((p) => p * log(p + 1e-10)).reduce((a, b) => a + b);
    final maxEntropy = log(scores.length.toDouble());
    return 1.0 - (entropy / maxEntropy);
  }
  
  List<String> _generateRecommendations(Map<String, double> riskScores, String taskType, DateTime targetTime) {
    final recommendations = <String>[];
    final forgetfulnessRisk = riskScores['forgetfulness']!;
    final delayRisk = riskScores['delay']!;
    final confidence = riskScores['confidence']!;
    
    // High forgetfulness risk
    if (forgetfulnessRisk > 0.7) {
      recommendations.add('HIGH RISK: Send multiple reminders starting 2 hours before');
      recommendations.add('Consider calling caregiver for direct intervention');
      recommendations.add('Use visual and audio cues simultaneously');
    } else if (forgetfulnessRisk > 0.5) {
      recommendations.add('MEDIUM RISK: Send reminder 1 hour before');
      recommendations.add('Use preferred notification method (audio/visual)');
    } else if (forgetfulnessRisk > 0.3) {
      recommendations.add('LOW RISK: Send standard reminder 30 minutes before');
    }
    
    // High delay risk
    if (delayRisk > 0.6) {
      recommendations.add('Patient may delay - send follow-up reminder 15 minutes after scheduled time');
      recommendations.add('Provide gentle encouragement about importance of timing');
    }
    
    // Low confidence predictions
    if (confidence < 0.4) {
      recommendations.add('Prediction confidence is low - use conservative reminder strategy');
    }
    
    // Time-specific recommendations
    final hour = targetTime.hour;
    if (hour < 8 || hour > 20) {
      recommendations.add('Off-hours medication - ensure caregiver is available');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Standard reminder protocol sufficient');
    }
    
    return recommendations;
  }
  
  // Helper methods for feature extraction
  Future<List<Map<String, dynamic>>> _getHistoricalData(String userId, String taskType, DateTime since) async {
    final collection = taskType == 'medication' ? 'medication_taken' : 'task_completions';
    final query = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThan: since.toUtc().toIso8601String())
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    
    return query.docs.map((doc) => doc.data()).toList();
  }
  
  Future<double> _getMedicationCount(String userId) async {
    // This would query user's medication list
    // For now, return a simulated value
    return 3.0;
  }
  
  Future<double> _getTaskCount(String userId) async {
    // This would query user's daily tasks
    // For now, return a simulated value
    return 5.0;
  }
  
  double _calculateCompletionRate(List<Map<String, dynamic>> historicalData) {
    if (historicalData.isEmpty) return 0.8; // Default good completion rate
    
    final totalTasks = historicalData.length;
    final completedTasks = historicalData.where((task) => task['completed'] == true).length;
    
    return completedTasks / totalTasks;
  }
  
  double _getTimeSinceLastMissed(List<Map<String, dynamic>> historicalData, DateTime now) {
    // Find most recent missed task/medication
    final missedTasks = historicalData.where((task) => task['completed'] == false).toList();
    
    if (missedTasks.isEmpty) return 1.0; // No recent misses
    
    final lastMissed = DateTime.parse(missedTasks.first['timestamp']);
    final hoursSince = now.difference(lastMissed).inHours;
    
    return (hoursSince / 168.0).clamp(0.0, 1.0); // Normalize to week
  }
  
  double _estimateStressLevel(List<Map<String, dynamic>> historicalData) {
    // Estimate stress based on completion patterns
    final recentData = historicalData.take(10).toList();
    final missedCount = recentData.where((task) => task['completed'] == false).length;
    
    return (missedCount / 10.0).clamp(0.0, 1.0);
  }
  
  double _estimateSleepQuality(DateTime targetTime) {
    // Estimate sleep quality based on time of day
    final hour = targetTime.hour;
    
    if (hour >= 6 && hour <= 10) return 0.8; // Good morning time
    if (hour >= 11 && hour <= 14) return 0.9; // Best cognitive time
    if (hour >= 15 && hour <= 18) return 0.7; // Afternoon dip
    if (hour >= 19 && hour <= 22) return 0.6; // Evening tiredness
    
    return 0.4; // Late night/early morning
  }
  
  double _getWeatherFactor(DateTime targetTime) {
    // Simulate weather impact (would integrate with weather API)
    final random = Random(targetTime.day);
    return 0.3 + (random.nextDouble() * 0.4); // 0.3 to 0.7
  }
  
  double _estimateSocialInteraction(DateTime targetTime) {
    // Estimate social interaction level based on time
    final hour = targetTime.hour;
    final dayOfWeek = targetTime.weekday;
    
    if (dayOfWeek >= 6) return 0.7; // Weekend - more social
    if (hour >= 9 && hour <= 17) return 0.5; // Work hours
    if (hour >= 18 && hour <= 21) return 0.8; // Evening social time
    
    return 0.3; // Low social interaction
  }
  
  double _detectRoutineDisruption(List<Map<String, dynamic>> historicalData, DateTime targetTime) {
    // Detect if today is different from usual routine
    final dayOfWeek = targetTime.weekday;
    final hour = targetTime.hour;
    
    final sameDayTasks = historicalData.where((task) {
      final taskTime = DateTime.parse(task['timestamp']);
      return taskTime.weekday == dayOfWeek && (taskTime.hour - hour).abs() <= 2;
    }).toList();
    
    if (sameDayTasks.isEmpty) return 0.8; // New/unusual time
    
    final completionValues = sameDayTasks.map((task) => task['completed'] == true ? 1.0 : 0.0).toList();
    final avgCompletionRate = completionValues.isEmpty ? 0.0 : completionValues.reduce((a, b) => a + b) / completionValues.length;
    return 1.0 - avgCompletionRate; // Higher disruption if usually missed
  }
  
  Future<double> _getMedicationComplexity(String userId, String itemName) async {
    // Calculate medication complexity (number of pills, frequency, etc.)
    // This would query medication details from database
    return 0.5; // Default medium complexity
  }
  
  double _calculateCognitiveLoad(double medicationCount, double taskCount) {
    // Calculate cognitive load based on total tasks
    final totalLoad = medicationCount + taskCount;
    return (totalLoad / 10.0).clamp(0.0, 1.0); // Normalize
  }
  
  double _calculateHistoricalPatternScore(List<Map<String, dynamic>> historicalData, DateTime targetTime) {
    // Calculate how well this time matches historical patterns
    final hour = targetTime.hour;
    final dayOfWeek = targetTime.weekday;
    
    final similarTasks = historicalData.where((task) {
      final taskTime = DateTime.parse(task['timestamp']);
      return taskTime.weekday == dayOfWeek && (taskTime.hour - hour).abs() <= 1;
    }).toList();
    
    if (similarTasks.isEmpty) return 0.5; // No historical data
    
    final successValues = similarTasks.map((task) => task['completed'] == true ? 1.0 : 0.0).toList();
    final successRate = successValues.isEmpty ? 0.0 : successValues.reduce((a, b) => a + b) / successValues.length;
    return successRate;
  }
  
  // Batch prediction for multiple items
  Future<List<PredictionResult>> predictMultipleItems(String userId, List<PredictionRequest> requests) async {
    final results = <PredictionResult>[];
    
    for (final request in requests) {
      final result = await predictForgetfulness(
        userId,
        taskType: request.taskType,
        targetTime: request.targetTime,
        itemName: request.itemName,
      );
      results.add(result);
    }
    
    return results;
  }
  
  // Store prediction results for model improvement
  Future<void> storePredictionResult(PredictionResult result) async {
    await _firestore.collection('ml_predictions').add({
      'userId': result.userId,
      'taskType': result.taskType,
      'itemName': result.itemName,
      'targetTime': result.targetTime.toUtc().toIso8601String(),
      'forgetfulnessRisk': result.forgetfulnessRisk,
      'delayRisk': result.delayRisk,
      'skipRisk': result.skipRisk,
      'confidence': result.confidence,
      'recommendations': result.recommendations,
      'predictionTime': result.predictionTime.toUtc().toIso8601String(),
    });
  }
}

// Data classes
class PredictionResult {
  final String userId;
  final String taskType;
  final String itemName;
  final DateTime targetTime;
  final double forgetfulnessRisk;
  final double delayRisk;
  final double skipRisk;
  final double confidence;
  final List<String> recommendations;
  final DateTime predictionTime;
  
  PredictionResult({
    required this.userId,
    required this.taskType,
    required this.itemName,
    required this.targetTime,
    required this.forgetfulnessRisk,
    required this.delayRisk,
    required this.skipRisk,
    required this.confidence,
    required this.recommendations,
    required this.predictionTime,
  });
  
  // Risk level helpers
  String get riskLevel {
    if (forgetfulnessRisk > 0.7) return 'HIGH';
    if (forgetfulnessRisk > 0.5) return 'MEDIUM';
    if (forgetfulnessRisk > 0.3) return 'LOW';
    return 'VERY LOW';
  }
  
  bool get needsIntervention => forgetfulnessRisk > 0.6 || delayRisk > 0.7;
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'taskType': taskType,
      'itemName': itemName,
      'targetTime': targetTime.toIso8601String(),
      'forgetfulnessRisk': forgetfulnessRisk,
      'delayRisk': delayRisk,
      'skipRisk': skipRisk,
      'confidence': confidence,
      'recommendations': recommendations,
      'predictionTime': predictionTime.toIso8601String(),
      'riskLevel': riskLevel,
      'needsIntervention': needsIntervention,
    };
  }
}

class PredictionRequest {
  final String taskType;
  final DateTime targetTime;
  final String itemName;
  
  PredictionRequest({
    required this.taskType,
    required this.targetTime,
    required this.itemName,
  });
}

