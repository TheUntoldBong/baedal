import 'package:flutter/material.dart';


class ColorConverter{
  static Color stringToColor(String? color){
    int value = 0xFFEF7822;
    if(color != null) {
      value = int.parse(color.replaceAll('#', '0xFF'));
    }
    return Color(value);
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF29A9E8);

      case 'processing':
        return const Color(0xFF29A9E8);

      case 'cooking':
        return const Color(0xFFF59E0B);

      case 'accepted':
        return const Color(0xFF10B981);

      case 'confirmed':
        return const Color(0xFF14B8A6);

      case 'handover':
        return const Color(0xFF8B5CF6);

      case 'ready_to_serve':
        return const Color(0xFF06B6D4);

      case 'picked_up':
        return const Color(0xFFF97316);

      case 'delivered':
        return const Color(0xFF22C55E);

      case 'active':
        return const Color(0xFF16A34A);

      case 'completed':
      case 'served':
        return const Color(0xFF059669);

      case 'paused':
        return const Color(0xFFEAB308);

      case 'canceled':
        return const Color(0xFFEF4444);

      case 'refunded':
        return const Color(0xFFE11D48);

      case 'refund_requested':
        return const Color(0xFFDB2777);

      case 'refund_request_canceled':
        return const Color(0xFF9F1239);

      case 'expired':
        return const Color(0xFF64748B);

      case 'failed':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFF6B7280);
    }
  }
}