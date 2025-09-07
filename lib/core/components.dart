import 'package:flutter/material.dart';
import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/model/user_summary.dart';

final Text mainTitle = const Text(
  "VidSummarizer",
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold
  )
);

/// Global dialog for loading scenarios
/// 
/// [ text ] Is the message to show while loading dialog is displayed
Dialog loadingDialog({
  required String text,
}) {
  return Dialog(
    backgroundColor: primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          CircularProgressIndicator.adaptive(backgroundColor: Colors.white, strokeWidth: 5),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white
            )
          )
        ],
      ),
    ),
  );
}

/// Custom InputDecoration for form fields
/// 
/// [ label ] Is the message to show in the TextFormField
InputDecoration defaultDecoration({
  required String label
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: Colors.white,
      fontSize: 16
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white
      )
    ),
    filled: true,
    fillColor: const Color.fromARGB(25, 255, 255, 255),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    errorStyle: const TextStyle(color: Colors.red),
  );
}

/// Custom InkWell button
/// 
/// [ label ] Is the text to show in the button
Ink defaultButton({
  required String label,
  bool isDeletion = false,
}) {
  return Ink(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isDeletion ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold
          )
        )
      ),
    ),
  );
}

/// Basic SnackBar for custom error message handling
/// 
/// [ content ] is the text that will be displayed
SnackBar defaultSnackBar(String content) {
  return SnackBar(
    content: Text(content, style: TextStyle(color: Colors.white)),
    backgroundColor: primaryDark,
  );
}

/// Default app bar for authentication screens
AppBar defaultBar() {
  return AppBar(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    title: mainTitle,
    centerTitle: true,
  );
}

/// App bar for main screen
/// 
/// [ settingsTap ] Is the callback to perform when the Settings icon is pressed
/// 
/// [ historyTap ] Is the callback to perform when the History icon is pressed
AppBar mainBar({
  required VoidCallback settingsTap,
  required VoidCallback historyTap
}) {
  return AppBar(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    automaticallyImplyLeading: false,
    leading: IconButton(
      onPressed: settingsTap,
      icon: Icon(Icons.settings_outlined),
    ),
    title: mainTitle,
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: historyTap,
        icon: Icon(Icons.history)
      )
    ]
  );
}

/// App bar for summary screen
AppBar summaryBar({
  required VoidCallback backTap,
  required VoidCallback downloadTap,
  required VoidCallback copyTap,
  required VoidCallback shareTap
}) {
  return AppBar(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    automaticallyImplyLeading: false,
    leading: IconButton(
      onPressed: backTap,
      icon: Icon(Icons.arrow_back)
    ),
    title: mainTitle,
    centerTitle: true,
    actions: [
      PopupMenuButton(
        color: primaryDark,
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: downloadTap,
            child: Text("Download summary", style: TextStyle(color: Colors.white))
          ),
          PopupMenuItem(
            onTap: copyTap,
            child: Text("Copy summary", style: TextStyle(color: Colors.white))
          ),
          PopupMenuItem(
            onTap: shareTap,
            child: Text("Share summary", style: TextStyle(color: Colors.white))
          )
        ],
      )
    ],
  );
}

/// App bar for history screen
AppBar historyBar({
  required VoidCallback backTap,
  required VoidCallback deleteTap,
  bool deleteMode = false
}) {
  return AppBar(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    automaticallyImplyLeading: false,
    leading: IconButton(
      onPressed: backTap,
      icon: Icon(Icons.arrow_back)
    ),
    title: mainTitle,
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: deleteTap,
        icon: Icon(Icons.delete_outline, color: deleteMode ? Colors.red : Color.fromARGB(50, 255, 255, 255))
      )
    ]
  );
}

/// Simple text column showing that a user has no summaries
Column noSummaries() {
  return const Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        "You don't have any summaries",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )
      ),
      SizedBox(height: 20),
      Text(
        "make some summaries now and one will show up here",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14
        ),
      )
    ],
  );
}

/// Summary card model for list of summaries
/// 
/// [ summary ] is the summary that is being rendered
Container summaryCard({required UserSummary summary}) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.white
      ),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.summaryName!,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 8),
        Divider(
          height: 1,
          color: Colors.white,
        ),
        SizedBox(height: 8),
        Text(
          "Created: ${formatDate(date: summary.createdAt!)}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w200
          ),
        )
      ],
    )
  );
}