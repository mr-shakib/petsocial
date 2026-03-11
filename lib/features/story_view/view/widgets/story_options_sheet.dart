import 'package:flutter/material.dart';

Future<void> showStoryOptionsSheet(
  BuildContext context,
  VoidCallback onDelete,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: ListTile(
        leading: const Icon(Icons.delete_outline, color: Colors.red),
        title: const Text('Delete story',
            style: TextStyle(color: Colors.red)),
        onTap: () {
          Navigator.pop(ctx);
          onDelete();
        },
      ),
    ),
  );
}
