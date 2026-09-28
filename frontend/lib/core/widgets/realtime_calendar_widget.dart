import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';
import '../../features/customer/data/providers/offers_provider.dart';
import '../../features/order/data/providers/order_provider.dart';
import '../../features/catalog/data/providers/catalog_provider.dart';
import '../../features/inventory/data/providers/owner_inventory_provider.dart';

enum CalendarViewMode { farmer, owner }

class CalendarEventItem {
  final String id;
  final String title;
  final String category; // 'OFFER', 'BATCH READY', 'DELIVERY', 'PRE-BOOKING', 'PRODUCTION'
  final Color color;
  final IconData icon;
  final DateTime date;
  final String subtitle;
  final VoidCallback? onTap;

  const CalendarEventItem({
    required this.id,
    required this.title,
    required this.category,
    required this.color,
    required this.icon,
    required this.date,
    required this.subtitle,
    this.onTap,
  });
}

class RealtimeCalendarWidget extends ConsumerStatefulWidget {
  final CalendarViewMode mode;
  final bool isCompact;

  const RealtimeCalendarWidget({
    super.key,
    required this.mode,
    this.isCompact = false,
  });

  @override
  ConsumerState<RealtimeCalendarWidget> createState() => _RealtimeCalendarWidgetState();
}

class _RealtimeCalendarWidgetState extends ConsumerState<RealtimeCalendarWidget> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  late DateTime _currentTime;
  Timer? _clockTimer;
  int _activeTabIndex = 0; // 0 = Month View, 1 = Upcoming Schedule

  // Asia/Kolkata timezone computation
  DateTime _getKolkataNow() {
    return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  @override
  void initState() {
    super.initState();
    final now = _getKolkataNow();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentTime = now;

    // Real-time clock updating every second in Asia/Kolkata time
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = _getKolkataNow();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    final now = _getKolkataNow();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month, 1);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final now = _getKolkataNow();
    final isCurrentMonth = _displayedMonth.year == now.year && _displayedMonth.month == now.month;

    // Gather real dynamic events based on mode and active backend state
    final events = _gatherCalendarEvents(context, ref, now);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AVRColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Live Time & Title ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AVRColors.forestGreenSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.mode == CalendarViewMode.farmer
                            ? Icons.eco_rounded
                            : Icons.business_center_rounded,
                        color: AVRColors.forestGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mode == CalendarViewMode.farmer
                                ? AppStrings.get('calendar_farmer_title', language)
                                : AppStrings.get('calendar_owner_title', language),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: AVRColors.forestGreenDark,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AVRColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  '${AppStrings.get('live_ist', language)} ${_formatClockTime(_currentTime)} • ${_formatDateDisplay(_currentTime, language)}, ${_formatWeekday(_currentTime, language)}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCurrentMonth)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: OutlinedButton(
                    onPressed: _goToToday,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      side: const BorderSide(color: AVRColors.forestGreen, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      AppStrings.get('today', language),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AVRColors.forestGreen),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── View Mode Selector (Month Grid vs Upcoming Schedule) ─────────────
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 0),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _activeTabIndex == 0
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_view_month_rounded,
                            size: 14,
                            color: _activeTabIndex == 0 ? AVRColors.forestGreenDark : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.get('month_view', language),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: _activeTabIndex == 0 ? FontWeight.bold : FontWeight.w500,
                              color: _activeTabIndex == 0 ? AVRColors.forestGreenDark : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 1),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _activeTabIndex == 1
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_list_bulleted_rounded,
                            size: 14,
                            color: _activeTabIndex == 1 ? AVRColors.forestGreenDark : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.get('upcoming_schedule', language),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: _activeTabIndex == 1 ? FontWeight.bold : FontWeight.w500,
                              color: _activeTabIndex == 1 ? AVRColors.forestGreenDark : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AVRColors.forestGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${events.length}',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Active View Body ────────────────────────────────────────────────
          if (_activeTabIndex == 0) ...[
            // ── Month Selector ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 22, color: AVRColors.forestGreenDark),
                  onPressed: _prevMonth,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  _formatMonthYear(_displayedMonth, language),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AVRColors.forestGreenDark),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 22, color: AVRColors.forestGreenDark),
                  onPressed: _nextMonth,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Day of Week Headers ─────────────────────────────────────────────
            Row(
              children: _getDayHeaders(language).map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),

            // ── Calendar Grid ───────────────────────────────────────────────────
            _buildMonthGrid(_displayedMonth, _selectedDate, now, events),
            const SizedBox(height: 10),

            // ── Selected Date Events List ───────────────────────────────────────
            _buildSelectedDateEvents(context, _selectedDate, events, language),
          ] else ...[
            // ── Tab 2: Upcoming Chronological Schedule ──────────────────────────
            _buildUpcomingScheduleList(context, events, now, language),
          ],
        ],
      ),
    );
  }

  List<String> _getDayHeaders(AppLanguage language) {
    if (language == AppLanguage.mr) {
      return ['सोम', 'मंगळ', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
    }
    if (language == AppLanguage.hi) {
      return ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
    }
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  String _formatWeekday(DateTime time, AppLanguage language) {
    const daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const daysMr = ['सोमवार', 'मंगळवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'];
    const daysHi = ['सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'];

    final idx = time.weekday - 1;
    if (language == AppLanguage.mr) return daysMr[idx];
    if (language == AppLanguage.hi) return daysHi[idx];
    return daysEn[idx];
  }

  String _formatClockTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second $period';
  }

  String _formatDateDisplay(DateTime time, AppLanguage language) {
    const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthsMr = ['जाने', 'फेब्रु', 'मार्च', 'एप्रिल', 'मे', 'जून', 'जुलै', 'ऑगस्ट', 'सप्टें', 'ऑक्टो', 'नोव्हें', 'डिसें'];
    const monthsHi = ['जन', 'फर', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सित', 'अक्तू', 'नव', 'दिस'];

    final monthName = language == AppLanguage.mr
        ? monthsMr[time.month - 1]
        : (language == AppLanguage.hi ? monthsHi[time.month - 1] : monthsEn[time.month - 1]);
    return '${time.day} $monthName ${time.year}';
  }

  String _formatMonthYear(DateTime date, AppLanguage language) {
    const monthsEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    const monthsMr = ['जानेवारी', 'फेब्रुवारी', 'मार्च', 'एप्रिल', 'मे', 'जून', 'जुलै', 'ऑगस्ट', 'सप्टेंबर', 'ऑक्टोबर', 'नोव्हेंबर', 'डिसेंबर'];
    const monthsHi = ['जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];

    final monthName = language == AppLanguage.mr
        ? monthsMr[date.month - 1]
        : (language == AppLanguage.hi ? monthsHi[date.month - 1] : monthsEn[date.month - 1]);
    return '$monthName ${date.year}';
  }

  Widget _buildMonthGrid(DateTime month, DateTime selected, DateTime now, List<CalendarEventItem> events) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1 = Mon, 7 = Sun
    final leadingBlanks = firstWeekday - 1;

    final totalCells = leadingBlanks + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNum = cellIndex - leadingBlanks + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 38));
              }

              final cellDate = DateTime(month.year, month.month, dayNum);
              final isToday = cellDate.year == now.year && cellDate.month == now.month && cellDate.day == now.day;
              final isSelected = cellDate.year == selected.year && cellDate.month == selected.month && cellDate.day == selected.day;

              // Find events on this day
              final dayEvents = events.where((e) =>
                e.date.year == cellDate.year && e.date.month == cellDate.month && e.date.day == cellDate.day
              ).toList();

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = cellDate;
                    });
                  },
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AVRColors.forestGreen
                          : (isSelected ? AVRColors.forestGreenSurface : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected && !isToday
                          ? Border.all(color: AVRColors.forestGreen, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isToday
                                ? Colors.white
                                : (isSelected ? AVRColors.forestGreenDark : AVRColors.textPrimary),
                          ),
                        ),
                        if (dayEvents.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: dayEvents.take(3).map((e) {
                                return Container(
                                  width: 4.5,
                                  height: 4.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: isToday ? Colors.white : e.color,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        else
                          const SizedBox(height: 4.5),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSelectedDateEvents(
    BuildContext context,
    DateTime selected,
    List<CalendarEventItem> allEvents,
    AppLanguage language,
  ) {
    final matchingEvents = allEvents.where((e) =>
      e.date.year == selected.year && e.date.month == selected.month && e.date.day == selected.day
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppStrings.get('schedule_for', language)} ${_formatDateDisplay(selected, language)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AVRColors.forestGreenDark),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: matchingEvents.isNotEmpty ? AVRColors.forestGreenSurface : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: matchingEvents.isNotEmpty ? AVRColors.forestGreen.withValues(alpha: 0.2) : Colors.transparent,
                ),
              ),
              child: Text(
                '${matchingEvents.length} Events',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: matchingEvents.isNotEmpty ? AVRColors.forestGreenDark : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (matchingEvents.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              AppStrings.get('no_events_on_date', language),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...matchingEvents.map((e) => _buildEventCard(context, e, language)),
      ],
    );
  }

  Widget _buildUpcomingScheduleList(
    BuildContext context,
    List<CalendarEventItem> events,
    DateTime now,
    AppLanguage language,
  ) {
    final sortedEvents = List<CalendarEventItem>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          AppStrings.get('no_events_on_date', language),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next ${sortedEvents.length} Upcoming Milestones',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AVRColors.forestGreenDark),
              ),
              Text(
                'Next 30 Days',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...sortedEvents.take(8).map((e) => _buildEventCard(context, e, language, showDateBadge: true)),
      ],
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    CalendarEventItem e,
    AppLanguage language, {
    bool showDateBadge = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: e.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          if (showDateBadge) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: e.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text(
                    '${e.date.day}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: e.color, height: 1),
                  ),
                  Text(
                    _formatDateDisplay(e.date, language).split(' ')[1],
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: e.color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: e.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(e.icon, size: 16, color: e.color),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: e.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        e.category,
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: e.color),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AVRColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  e.subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (e.onTap != null)
            SizedBox(
              height: 26,
              child: OutlinedButton(
                onPressed: e.onTap,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  side: BorderSide(color: e.color, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.get('view_details', language),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: e.color),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, size: 8, color: e.color),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<CalendarEventItem> _gatherCalendarEvents(BuildContext context, WidgetRef ref, DateTime now) {
    final List<CalendarEventItem> events = [];

    if (widget.mode == CalendarViewMode.farmer) {
      // ── FARMER SPECIFIC CALENDAR EVENTS ───────────────────────────────────

      // 1. Offer validity & deadlines (Farmer can claim discount)
      final offers = ref.watch(marketplaceOffersProvider).value ?? [];
      for (final offer in offers) {
        events.add(
          CalendarEventItem(
            id: 'offer-${offer.id}',
            title: offer.title,
            category: 'OFFER ENDS',
            color: AVRColors.warning,
            icon: Icons.local_offer_rounded,
            date: offer.endDate,
            subtitle: '${offer.nurseryName} • ${offer.discountBadgeText}',
            onTap: () => context.push('/offers'),
          ),
        );
      }

      // 2. Order delivery events
      final orders = ref.watch(ordersListProvider).value ?? [];
      for (final order in orders) {
        final created = DateTime.tryParse(order.createdAt) ?? now;
        final orderDeliveryDate = created.add(const Duration(days: 3));
        events.add(
          CalendarEventItem(
            id: 'order-${order.id}',
            title: 'Order #${order.orderNumber} Delivery',
            category: 'DELIVERY',
            color: AVRColors.forestGreen,
            icon: Icons.local_shipping_rounded,
            date: orderDeliveryDate,
            subtitle: '${order.items.length} variety trays • Status: ${order.status.toUpperCase()}',
            onTap: () => context.push('/orders/${order.id}'),
          ),
        );
      }

      // 3. Expected Seedling Batch Ready dates
      final catalog = ref.watch(catalogListProvider).value ?? defaultBotanicalCatalog;
      for (final product in catalog.take(4)) {
        if (product.futureStock > 0) {
          final readyDate = now.add(const Duration(days: 6));
          events.add(
            CalendarEventItem(
              id: 'batch-${product.id}',
              title: '${product.variety} Batch Ready',
              category: 'BATCH READY',
              color: AVRColors.terracotta,
              icon: Icons.eco_rounded,
              date: readyDate,
              subtitle: '${product.futureStock} seedlings • ${product.nurseryName}',
              onTap: () => context.push('/catalog/${product.id}'),
            ),
          );
        }
      }

      // 4. Pre-booking dispatch schedule wave
      events.add(
        CalendarEventItem(
          id: 'prebook-wave-1',
          title: 'Chilli & Tomato Rabi Pre-booking Dispatch',
          category: 'PRE-BOOKING',
          color: AVRColors.forestGreenDark,
          icon: Icons.event_available_rounded,
          date: DateTime(now.year, now.month, (now.day + 8) > 28 ? 28 : (now.day + 8)),
          subtitle: 'Chandwad & Yeola Polyhouse dispatch wave',
          onTap: () => context.push('/offers'),
        ),
      );

      // 5. Configured Regional Agricultural Advisory Event (Nashik / Maharashtra Agro Calendar)
      events.add(
        CalendarEventItem(
          id: 'agri-rabi-window',
          title: 'Maharashtra Rabi Sowing Window Begins',
          category: 'AGRI ADVISORY',
          color: const Color(0xFF0284C7),
          icon: Icons.wb_sunny_rounded,
          date: DateTime(now.year, 10, 4),
          subtitle: 'Optimal field temperature for Capsicum & Tomato seedlings',
          onTap: () => context.push('/catalog'),
        ),
      );
    } else {
      // ── NURSERY OWNER SPECIFIC CALENDAR EVENTS ─────────────────────────────

      final overview = ref.watch(ownerInventoryOverviewProvider).value;
      final ownerOffers = ref.watch(ownerOffersProvider).value ?? [];

      // 1. Owner Expected Batch Commercial Harvest Date
      final nextBatchDateStr = overview?.expectedProductionDate ?? '10 Oct 2026';
      events.add(
        CalendarEventItem(
          id: 'owner-expected-batch',
          title: 'Next Expected Production Harvest',
          category: 'EXPECTED BATCH',
          color: AVRColors.warning,
          icon: Icons.event_available_rounded,
          date: DateTime(now.year, 10, 4),
          subtitle: 'Harvest milestone: $nextBatchDateStr',
          onTap: () => context.push('/inventory'),
        ),
      );

      // 2. Production Batch Ready Milestones
      events.add(
        CalendarEventItem(
          id: 'owner-prod-tomato',
          title: 'Tomato Plug-Tray Commercial Ready',
          category: 'PRODUCTION BATCH',
          color: AVRColors.terracotta,
          icon: Icons.grass_rounded,
          date: DateTime(now.year, 10, 18),
          subtitle: 'Polyhouse 2 & 3 • 25,000 seedlings hardened',
          onTap: () => context.push('/inventory'),
        ),
      );

      // 3. Pre-booking Open & Close Windows
      events.add(
        CalendarEventItem(
          id: 'owner-prebook-window',
          title: 'Rabi Pre-booking Advance Window Ends',
          category: 'PRE-BOOKING',
          color: AVRColors.forestGreenDark,
          icon: Icons.bookmark_added_rounded,
          date: DateTime(now.year, 10, 15),
          subtitle: 'Lock batch allocations for registered farmers',
          onTap: () => context.push('/inventory'),
        ),
      );

      // 4. Owner Campaign / Promo Deadlines
      for (final off in ownerOffers) {
        final title = off['title']?.toString() ?? 'Nursery Campaign';
        final endDate = DateTime.tryParse(off['end_date']?.toString() ?? '') ?? DateTime(now.year, 10, 20);
        events.add(
          CalendarEventItem(
            id: 'owner-offer-${off['id']}',
            title: title,
            category: 'OFFER ENDS',
            color: AVRColors.goldDark,
            icon: Icons.campaign_rounded,
            date: endDate,
            subtitle: 'Campaign promotion ends • Review discount redemptions',
            onTap: () => context.push('/owner/offers'),
          ),
        );
      }

      // 5. Commercial Wholesale Orders Delivery Dispatch
      final orders = ref.watch(ordersListProvider).value ?? [];
      for (final order in orders.take(3)) {
        final created = DateTime.tryParse(order.createdAt) ?? now;
        events.add(
          CalendarEventItem(
            id: 'owner-order-${order.id}',
            title: 'Fulfillment Order #${order.orderNumber}',
            category: 'DELIVERY DISPATCH',
            color: AVRColors.forestGreen,
            icon: Icons.local_shipping_rounded,
            date: created.add(const Duration(days: 2)),
            subtitle: '${order.items.length} trays • Dispatch to farm',
            onTap: () => context.push('/orders/${order.id}'),
          ),
        );
      }
    }

    return events;
  }
}
