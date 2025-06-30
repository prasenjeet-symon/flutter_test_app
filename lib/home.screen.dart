import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UsageHistoryScreen extends StatelessWidget {
  const UsageHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF616161), size: 24), onPressed: () {}),
        title: const SearchBarWidget(),
        actions: [IconButton(icon: const Icon(Icons.filter_list, color: Color(0xFF616161), size: 20), onPressed: () {}), IconButton(icon: const Icon(Icons.calendar_today, color: Color(0xFF616161), size: 20), onPressed: () {}), SizedBox(width: 8.w)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DateGroupWidget(date: '18 Mar 2025', items: [HistoryItemData(iconUrl: 'https://picsum.photos/40/40?random=1', orgName: 'Google', planName: 'Cloud Platform Subscription', coins: '9 Coins Used at 06:33 PM')]),
            DateGroupWidget(
              date: '10 Mar 2025',
              items: [
                HistoryItemData(iconUrl: 'https://picsum.photos/40/40?random=2', orgName: 'Microsoft', planName: 'Azure Enterprise Plan', coins: '25 Coins Used at 03:07 PM'),
                HistoryItemData(iconUrl: 'https://picsum.photos/40/40?random=6', orgName: 'Salesforce', planName: 'CRM Starter Plan', coins: '25 Coins Used at 03:07 PM'),
              ],
            ),
            DateGroupWidget(
              date: '09 Mar 2025',
              items: [
                HistoryItemData(iconUrl: 'https://picsum.photos/40/40?random=3', orgName: 'Amazon', planName: 'AWS Free Tier', coins: '12 Coins Used at 05:21 PM'),
                HistoryItemData(iconUrl: 'https://picsum.photos/40/40?random=5', orgName: 'Oracle', planName: 'Database Cloud Service', coins: '12 Coins Used at 05:21 PM'),
              ],
            ),
            DateGroupWidget(date: '06 Mar 2025', items: [HistoryItemData(iconUrl: 'https://picsum.photos/40/40?random=4', orgName: 'IBM', planName: 'Watson AI Services', coins: '11 Coins Used at 11:21 AM')]),
          ],
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        children: [
          Icon(Icons.search, color: const Color(0xFF616161), size: 18.w),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: 'Search by org or plan name', hintStyle: TextStyle(color: const Color(0xFF757575), fontSize: 14.sp), border: InputBorder.none),
              style: TextStyle(color: const Color(0xFF212121), fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class DateGroupWidget extends StatelessWidget {
  final String date;
  final List<HistoryItemData> items;

  const DateGroupWidget({super.key, required this.date, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF757575))),
          SizedBox(height: 8.h),
          if (items.length > 1) ...[HistoryItemWidget(item: items[0]), SizedBox(height: 8.h), HistoryItemWidget(item: items[1])] else ...[HistoryItemWidget(item: items[0])],
        ],
      ),
    );
  }
}

class HistoryItemData {
  final String iconUrl;
  final String orgName;
  final String planName;
  final String coins;

  HistoryItemData({required this.iconUrl, required this.orgName, required this.planName, required this.coins});
}

class HistoryItemWidget extends StatelessWidget {
  final HistoryItemData item;

  const HistoryItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle tap action here
      },
      splashColor: Colors.grey.withOpacity(0.3),
      highlightColor: Colors.grey.withOpacity(0.1),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA), // Updated to a very light gray
          border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Row(
          children: [
            Container(width: 40.w, height: 40.w, decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(item.iconUrl), fit: BoxFit.cover))),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.orgName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF212121))),
                  SizedBox(height: 4.h),
                  Text(item.planName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: const Color(0xFF616161))),
                  SizedBox(height: 4.h),
                  Text(item.coins, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF388E3C))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: const Color(0xFF616161), size: 20.w),
          ],
        ),
      ),
    );
  }
}
