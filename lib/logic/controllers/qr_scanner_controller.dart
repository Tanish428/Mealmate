import 'package:flutter/material.dart';
import 'dart:convert';
import '../../data/repos/mess_repo.dart';

enum QrScanResultType { joinMess, attendance, unknown }

class QrScanResult {
  final QrScanResultType type;
  final String rawData;
  final String? inviteCode;
  final String? memberId;
  final String? mealType;

  const QrScanResult({
    required this.type,
    required this.rawData,
    this.inviteCode,
    this.memberId,
    this.mealType,
  });
}

class QrScannerController extends ChangeNotifier {
  final MessRepository _messRepo;

  bool _isProcessing = false;
  String? _lastScannedCode;
  String? _statusMessage;
  String? _errorMessage;
  bool _isSuccess = false;
  QrScanResult? _lastResult;

  QrScannerController({MessRepository? messRepo})
      : _messRepo = messRepo ?? MessRepository();

  bool get isProcessing => _isProcessing;
  String? get lastScannedCode => _lastScannedCode;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  QrScanResult? get lastResult => _lastResult;

  void reset() {
    _isProcessing = false;
    _lastScannedCode = null;
    _statusMessage = null;
    _errorMessage = null;
    _isSuccess = false;
    _lastResult = null;
    notifyListeners();
  }

  /// Parses a raw QR code string into structured scan data.
  QrScanResult parseCode(String raw) {
    final trimmed = raw.trim();

    // Check if JSON formatted
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final Map<String, dynamic> data = jsonDecode(trimmed);
        if (data.containsKey('invite_code') || data.containsKey('inviteCode')) {
          return QrScanResult(
            type: QrScanResultType.joinMess,
            rawData: trimmed,
            inviteCode: (data['invite_code'] ?? data['inviteCode']).toString(),
          );
        } else if (data.containsKey('member_id') || data.containsKey('memberId')) {
          return QrScanResult(
            type: QrScanResultType.attendance,
            rawData: trimmed,
            memberId: (data['member_id'] ?? data['memberId']).toString(),
            mealType: (data['meal_type'] ?? data['mealType'])?.toString(),
          );
        }
      } catch (_) {}
    }

    // Alphanumeric invite code (typically 6 characters)
    if (RegExp(r'^[A-Z0-9]{5,8}$', caseSensitive: false).hasMatch(trimmed)) {
      return QrScanResult(
        type: QrScanResultType.joinMess,
        rawData: trimmed,
        inviteCode: trimmed.toUpperCase(),
      );
    }

    return QrScanResult(
      type: QrScanResultType.unknown,
      rawData: trimmed,
    );
  }

  /// Processes an invite code to join a mess.
  Future<bool> joinMessWithCode(String rawCode) async {
    final parsed = parseCode(rawCode);
    final inviteCode = parsed.inviteCode ?? rawCode.trim().toUpperCase();

    if (inviteCode.isEmpty) {
      _errorMessage = 'Invalid QR code or invite code.';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    _statusMessage = 'Joining mess...';
    _isSuccess = false;
    notifyListeners();

    try {
      await _messRepo.joinMess(inviteCode: inviteCode);
      _isSuccess = true;
      _statusMessage = 'Successfully joined the mess!';
      _lastScannedCode = inviteCode;
      _lastResult = parsed;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _statusMessage = null;
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
