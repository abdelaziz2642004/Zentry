import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

SnackBar failedSnackBar({
  String msg = 'Unfortunately :(',
  String title = 'Failed!',
}) {
  return SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,

    content: AwesomeSnackbarContent(
      title: title,
      message: msg,
      contentType: ContentType.failure,
    ),
  );
}
