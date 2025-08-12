import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/custom_container.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/custom_text_form_field.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/capacity_button.dart';

class Capacity extends StatelessWidget {
  final TextEditingController capacityController;
  final VoidCallback incrementCapacity;
  final VoidCallback decrementCapacity;

  const Capacity({
    super.key,
    required this.capacityController,
    required this.incrementCapacity,
    required this.decrementCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CapacityButton(
            icon: Icons.remove,
            onTap: () {
              decrementCapacity();
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: CustomContainer(
              child: CustomTextFormField(
                controller: capacityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "*Required";
                  }

                  final intValue = int.tryParse(value);
                  if (intValue == null) {
                    return "not valid";
                  }

                  if (intValue > 50) {
                    return "should be <= 50";
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: CapacityButton(
            icon: Icons.add,
            onTap: () {
              incrementCapacity();
            },
          ),
        ),
      ],
    );
  }
}
