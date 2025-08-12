import 'package:flutter/material.dart';

// モーダルを閉じてスナックバー表示
void closeModalWithSnackBar(BuildContext context, String message) {
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.fixed,
    ),
  );
}
