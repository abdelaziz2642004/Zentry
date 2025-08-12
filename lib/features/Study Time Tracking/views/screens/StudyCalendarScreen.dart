import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/daily_study_service.dart';

class StudyCalendarScreen extends StatefulWidget {
  const StudyCalendarScreen({super.key});

  @override
  State<StudyCalendarScreen> createState() => _StudyCalendarScreenState();
}

class _StudyCalendarScreenState extends State<StudyCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, Duration> _monthlyData = {};
  bool _isLoading = true;
  final DailyStudyService _studyService = DailyStudyService();

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _studyService.getStudyTimeForMonth(
        _selectedDate.year,
        _selectedDate.month,
      );
      setState(() {
        _monthlyData = data;
        _isLoading = false;
      });
    } on Exception catch (e) {
      e;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Calendar'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadMonthlyData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildMonthHeader(),
                  _buildCalendarGrid(),
                  const SizedBox(height: 16),
                  _buildStatistics(),
                ],
              ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                );
              });
              _loadMonthlyData();
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                );
              });
              _loadMonthlyData();
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Weekday headers
            Row(
              children:
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map(
                        (day) => Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            // Calendar grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: 42, // 6 weeks * 7 days
                itemBuilder: (context, index) {
                  final dayOffset = index - (firstWeekday - 1);
                  final day = dayOffset + 1;

                  if (day <= 0 || day > daysInMonth) {
                    return Container(); // Empty space
                  }

                  final dateString =
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                  final studyTime = _monthlyData[dateString] ?? Duration.zero;
                  final isToday = _isToday(day);
                  final isSelected = _isSelectedDay(day);

                  return _buildCalendarDay(day, studyTime, isToday, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(
    int day,
    Duration studyTime,
    bool isToday,
    bool isSelected,
  ) {
    final hasStudyTime = studyTime.inMinutes > 0;
    final studyHours = studyTime.inHours;
    final studyMinutes = studyTime.inMinutes % 60;

    Color backgroundColor;
    Color textColor;

    if (isSelected) {
      backgroundColor = Colors.blue[100]!;
      textColor = Colors.blue[800]!;
    } else if (isToday) {
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
    } else if (hasStudyTime) {
      backgroundColor = Colors.green[100]!;
      textColor = Colors.green[800]!;
    } else {
      backgroundColor = Colors.grey[50]!;
      textColor = Colors.grey[600]!;
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toString(),
            style: TextStyle(
              fontWeight:
                  isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              color: textColor,
              fontSize: 14,
            ),
          ),
          if (hasStudyTime) ...[
            const SizedBox(height: 2),
            Text(
              studyHours > 0
                  ? '${studyHours}h${studyMinutes > 0 ? ' ${studyMinutes}m' : ''}'
                  : '${studyMinutes}m',
              style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final totalStudyTime = _monthlyData.values.fold<Duration>(
      Duration.zero,
      (total, duration) => total + duration,
    );

    final studyDays = _monthlyData.values.where((d) => d.inMinutes > 0).length;
    final averageStudyTime =
        studyDays > 0
            ? Duration(minutes: totalStudyTime.inMinutes ~/ studyDays)
            : Duration.zero;

    final bestDay = _getBestStudyDay();
    final totalHours = totalStudyTime.inHours;
    final totalMinutes = totalStudyTime.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Study Time',
                  '${totalHours}h ${totalMinutes}m',
                  Icons.timer,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Study Days',
                  '$studyDays days',
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Average/Day',
                  averageStudyTime.inMinutes > 0
                      ? '${averageStudyTime.inHours}h ${averageStudyTime.inMinutes % 60}m'
                      : '0m',
                  Icons.analytics,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Best Day',
                  bestDay.isNotEmpty ? bestDay : 'None',
                  Icons.star,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.day == day &&
        now.month == _selectedDate.month &&
        now.year == _selectedDate.year;
  }

  bool _isSelectedDay(int day) {
    // You can implement selection logic here
    return false;
  }

  String _getBestStudyDay() {
    if (_monthlyData.isEmpty) return '';

    String bestDay = '';
    Duration maxTime = Duration.zero;

    _monthlyData.forEach((date, duration) {
      if (duration > maxTime) {
        maxTime = duration;
        final parts = date.split('-');
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        bestDay = '${_getMonthName(month)} $day';
      }
    });

    return bestDay;
  }
}
