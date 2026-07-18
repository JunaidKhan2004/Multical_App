import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculation_history.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final bool isDark;
  final void Function(String expr) onRecall;

  const HistoryScreen({
    super.key,
    required this.isDark,
    required this.onRecall,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = HistoryService();
  late List<CalculationHistory> _items;

  @override
  void initState() {
    super.initState();
    _items = _service.getAll();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            widget.isDark ? AppColors.darkSurface : AppColors.lightBg,
        title: Text(
          'Clear History',
          style: GoogleFonts.spaceMono(
            color: widget.isDark ? AppColors.cream : AppColors.deepest,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Delete all calculation history?',
          style: GoogleFonts.spaceMono(
            color: widget.isDark ? AppColors.cream : AppColors.deepest,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.spaceMono(color: AppColors.medium)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear',
                style: GoogleFonts.spaceMono(
                    color: AppColors.cream,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.clearAll();
      setState(() => _items = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface =
        widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        widget.isDark ? AppColors.cream : AppColors.deepest;
    final dimColor = textColor.withAlpha(150);
    final borderColor =
        widget.isDark ? AppColors.dark : AppColors.medium;

    return Theme(
      data: widget.isDark ? AppTheme.dark : AppTheme.light,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: surface,
          title: Text(
            'HISTORY',
            style: GoogleFonts.spaceMono(
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          iconTheme: IconThemeData(color: textColor),
          actions: [
            if (_items.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear all',
                onPressed: _clearAll,
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Container(
              height: 3,
              color: borderColor,
            ),
          ),
        ),
        body: _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 64, color: dimColor),
                    const SizedBox(height: 12),
                    Text(
                      'No history yet',
                      style: GoogleFonts.spaceMono(
                        color: dimColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length,
                separatorBuilder: (_, __) => Divider(
                  color: borderColor.withAlpha(80),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (_, i) {
                  final item = _items[i];
                  final time = _formatTime(item.timestamp);
                  return InkWell(
                    onTap: () {
                      widget.onRecall(item.result);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.expression,
                                  style: GoogleFonts.spaceMono(
                                    color: dimColor,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '= ${item.result}',
                                  style: GoogleFonts.spaceMono(
                                    color: textColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                time,
                                style: GoogleFonts.spaceMono(
                                  color: dimColor,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Icon(Icons.north_west,
                                  size: 14, color: dimColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
