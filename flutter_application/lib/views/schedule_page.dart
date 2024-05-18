import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  final String userId;

  const SchedulePage({super.key, required this.userId});

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  late Map<DateTime, List<Activity>> _events;
  late List<Activity> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    List<Activity> activities =
        await BackendService().getUserActivities(widget.userId, 0, 100);
    setState(() {
      _events = {};
      for (var activity in activities) {
        final day = DateTime(activity.scheduledDateTime.year,
            activity.scheduledDateTime.month, activity.scheduledDateTime.day);
        if (_events[day] == null) {
          _events[day] = [];
        }
        _events[day]!.add(activity);
      }
      _selectedEvents = _events[_selectedDay] ?? [];
      _isLoading = false;
    });
  }

  List<Activity> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'My Schedule',
        context: context,
      ),
      body: DefaultBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2999, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: _onDaySelected,
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: _getEventsForDay,
                    ),
                    const SizedBox(height: 8.0),
                    ..._selectedEvents.map((event) => ListTile(
                          title: Text(event.name),
                          subtitle: Text(
                              event.scheduledDateTime.toLocal().toString()),
                        )),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
