import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MalaTransaction {
  final String id;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int malaCount;

  const MalaTransaction({required this.id, required this.startDateTime, required this.endDateTime, required this.malaCount});
}

class JapaHistoryScreen extends StatefulWidget {
  final List<MalaTransaction> transactions;
  final void Function(DateTimeRange?)? onDateRangeSelected;
  final DateTimeRange? defaultDateRange;

  const JapaHistoryScreen({super.key, required this.transactions, this.onDateRangeSelected, this.defaultDateRange});

  @override
  State<JapaHistoryScreen> createState() => _JapaHistoryScreenState();
}

class _JapaHistoryScreenState extends State<JapaHistoryScreen> {
  late DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = widget.defaultDateRange;
  }

  // Group transactions by date
  Map<String, List<MalaTransaction>> _groupByDate() {
    final dateFormat = DateFormat('dd MMM yyyy');
    final Map<String, List<MalaTransaction>> grouped = {};
    for (var transaction in widget.transactions) {
      final date = dateFormat.format(transaction.startDateTime);
      grouped.putIfAbsent(date, () => []).add(transaction);
    }
    return grouped;
  }

  // Handle date range selection
  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF000000), onPrimary: Colors.white, surface: Colors.white)), child: child!);
      },
    );
    if (selectedRange != null) {
      setState(() {
        _selectedDateRange = selectedRange;
      });
      if (widget.onDateRangeSelected != null) {
        widget.onDateRangeSelected!(selectedRange);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _groupByDate();
    final dateFormat = DateFormat('dd MMM yyyy');
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F5F5),
            elevation: 0,
            leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp), onPressed: () => Navigator.pop(context)),
            title: Text('Japa History', style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600)),
            centerTitle: true,
            actions: [Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: IconButton(icon: Icon(Icons.calendar_today, size: 18.sp, color: const Color(0xFF333333)), onPressed: () => _selectDateRange(context)))],
          ),
          body: Column(
            children: [
              if (_selectedDateRange != null)
                GestureDetector(
                  onTap: () => _selectDateRange(context),
                  child: Container(
                    width: 360.w,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    color: Colors.white,
                    child: Text('${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w500)),
                  ),
                ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 360.w,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4.r, offset: Offset(0, 2.h))]),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children:
                          groupedTransactions.entries.map((entry) {
                            return Padding(padding: EdgeInsets.only(bottom: 8.h), child: DateSectionWidget(date: entry.key, transactions: entry.value));
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DateSectionWidget extends StatelessWidget {
  final String date;
  final List<MalaTransaction> transactions;

  const DateSectionWidget({super.key, required this.date, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), child: Text(date, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w600))),
        Container(
          color: const Color(0xFFF9FAFF),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(children: [const HeaderRowWidget(), Column(children: transactions.map((transaction) => TransactionRowWidget(transaction: transaction)).toList())]),
        ),
        const Divider(color: Color(0xFFE0E0E0), height: 1),
      ],
    );
  }
}

class HeaderRowWidget extends StatelessWidget {
  const HeaderRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Start Time', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF666666), fontWeight: FontWeight.w600, textBaseline: TextBaseline.alphabetic))),
          Expanded(flex: 3, child: Text('End Time', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF666666), fontWeight: FontWeight.w600, textBaseline: TextBaseline.alphabetic), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Mala Count', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF666666), fontWeight: FontWeight.w600, textBaseline: TextBaseline.alphabetic), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class TransactionRowWidget extends StatelessWidget {
  final MalaTransaction transaction;

  const TransactionRowWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(timeFormat.format(transaction.startDateTime), style: TextStyle(fontSize: 14.sp, color: const Color(0xFF000000), textBaseline: TextBaseline.alphabetic))),
          Expanded(flex: 3, child: Text(timeFormat.format(transaction.endDateTime), style: TextStyle(fontSize: 14.sp, color: const Color(0xFF000000), textBaseline: TextBaseline.alphabetic), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('${transaction.malaCount}', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF000000), textBaseline: TextBaseline.alphabetic), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
