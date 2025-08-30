import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class SimpleTabTest extends StatefulWidget {
  const SimpleTabTest({super.key});

  @override
  State<SimpleTabTest> createState() => _SimpleTabTestState();
}

class _SimpleTabTestState extends State<SimpleTabTest>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Tabs'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: mainColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: mainColor,
          tabs: const [Tab(text: 'Tab 1'), Tab(text: 'Tab 2')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Tab 1 Content')),
          Center(child: Text('Tab 2 Content')),
        ],
      ),
    );
  }
}
