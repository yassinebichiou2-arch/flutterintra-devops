import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black45,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                          color: AppTheme.primary),
                      if (message != null) ...[
                        const SizedBox(height: 14),
                        Text(message!,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}




