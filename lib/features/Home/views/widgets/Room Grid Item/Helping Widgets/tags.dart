import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/custom_container.dart';
import '../../../../../../core/colors.dart';

class Tags extends StatelessWidget {
  const Tags({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          height: 28,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: CustomContainer(
                  color: secondaryColor,
                  blurRadius: 1,
                  vPadding: 0,
                  hPadding: 8,
                  child: Text(
                    "#${tags[index]}",
                    style: const TextStyle(fontSize: 8, color: white),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return Container(height: 12);
  }
}
