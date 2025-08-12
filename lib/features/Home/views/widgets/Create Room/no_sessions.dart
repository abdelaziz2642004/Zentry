import 'package:flutter/material.dart';

import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/custom_container.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/custom_text_form_field.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/form_text_title.dart';

class NumberOfSessions extends StatelessWidget {
  const NumberOfSessions({super.key, required this.numberOfSessionsController});

  final TextEditingController numberOfSessionsController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 3,
          child: FormTextTitle(text: AppConstants.numberOfSessions),
        ),
        Expanded(
          flex: 1,
          child: CustomContainer(
            child: CustomTextFormField(
              controller: numberOfSessionsController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "*Required";
                }

                final intValue = int.tryParse(value);
                if (intValue == null) {
                  return "not valid";
                }

                if (intValue <= 0) {
                  return AppConstants.shouldBeGreaterThanZero;
                }

                if (intValue > Dimensions.maxSessions) {
                  return "${AppConstants.shouldBeLessThanOrEqualTo}${Dimensions.maxSessions}";
                }
                return null;
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
