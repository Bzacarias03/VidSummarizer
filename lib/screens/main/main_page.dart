import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:vidsummarizer/core/components.dart';
import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/core/openai.dart';
import 'package:vidsummarizer/core/scraper/scraper.dart';
import 'package:vidsummarizer/model/user_preferences.dart';
import 'package:vidsummarizer/screens/auth/login_page.dart';
import 'package:vidsummarizer/screens/main/history_page.dart';
import 'package:vidsummarizer/screens/main/settings_page.dart';
import 'package:vidsummarizer/screens/main/summary_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Scraper scraper = Scraper();
  final OpenAIClient _aiClient = OpenAIClient();

  final TextEditingController _urlController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String _selectedLanguageType = languageTypes[0];
  int _languageIndex = 0;

  String _selectedSummaryType = summaryTypes[0];
  int _summaryIndex = 0;

  @override
  void initState() {
    _setPreferences();
    super.initState();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _setPreferences() async {
    int savedLanguageType = realtimeManager.preferences.languageType!;
    int savedSummaryType = realtimeManager.preferences.summaryType!;

    setState(() {
      _selectedLanguageType = languageTypes[savedLanguageType];
      _languageIndex = savedLanguageType;

      _selectedSummaryType = summaryTypes[savedSummaryType];
      _summaryIndex = savedSummaryType;
    });
  }

  String? _urlValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a link";
    }
    if (!value.contains(webLink) && !value.contains(mobileLink)) {
      return "This is not a valid link";
    }

    return null;
  }

  Future<void> _showDialog(String content) {
    return showDialog(
      context: context,
      builder: (context) => loadingDialog(text: content)
    );
  }

  void _dismissDialog() {
    Navigator.of(context).pop();
  }

  Future<void> _summarize() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _showDialog("Fetching captions and generating summary");

    final url = _urlController.text.trim();
    try {
      String captions = await scraper.getCaptions(url);
      String summary = await _aiClient.generateSummary(
        captions: captions,
        languageType: _selectedLanguageType,
        summaryType: _selectedSummaryType
      );
      Map<String, dynamic> metadata = await scraper.getMetadata(url);

      Map<String, dynamic> content = {
        "captions": captions,
        "summary": summary,
        "metadata": metadata
      };

      _dismissDialog();
      _urlController.clear();
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SummaryPage(content: content))
        );
      }
    }
    catch (error) {
      _dismissDialog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          defaultSnackBar("There was an error generating your summary. Try again later")
        );
      }
    }
  }

  Future<void> _signOut() async {
    _showDialog("Signing out");
    
    try {
      await authManager.signout();
      realtimeManager.clean();
      
      _dismissDialog();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false
        );
      }
    }
    catch(error) {
      _dismissDialog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          defaultSnackBar("There was an error signing out. Try again later")
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: mainBar(
        settingsTap: () => _scaffoldKey.currentState!.openDrawer(),
        historyTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HistoryPage())
        )
      ),
      drawer: _createDrawer(),
      body: _createBody(),
    );
  }

  Widget _createBody() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 24),
          Text(
            "Enter a youtube link here",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22
            ),
          ),
          SizedBox(height: 16),
          Form(
            key: _formKey,
            child: _createFormField(
              label: "Youtube Link",
              controller: _urlController,
              validator: _urlValidator
            )
          ),
          SizedBox(height: 32),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: _summarize,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle
              ),
              child: Center(
                child: Text(
                  "Summarize",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )
          ),
          SizedBox(height: 32),
          Divider(
            height: 1,
            color: Color.fromARGB(35, 255, 255, 255),
          ),
          SizedBox(height: 32),
          Text(
            "Recent Summary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 32),
          SummaryCard()
        ],
      ),
    );
  }

  Widget _createDrawer() {
    return Drawer(
      child: Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              color: Color.fromARGB(35, 255, 255, 255)
            )
          ),
          actions: [
            IconButton(
              onPressed: () => _scaffoldKey.currentState!.closeDrawer(),
              icon: Icon(Icons.arrow_forward)
            ),
          ],
        ),
        body: _createDrawerBody()
      )
    );
  }

  Widget _createDrawerBody() {
    return Padding(
      padding: EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                _createLanguageSelector(),
                SizedBox(height: 32),
                _createSummaryTypeSelector(),
                SizedBox(height: 24),
              ],
            )
          ),
          InkWell(
            onTap: () => {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsPage()) 
              )
            },
            child: defaultButton(label: "Account")
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: _signOut,
            child: defaultButton(label: "Sign out"),
          )
        ],
      ),
    );
  }

  Widget _createLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 6,
          children: [
            Icon(
              Icons.language,
              color: Colors.white,
              size: 24,
            ),
            Text(
              "Language Type",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
        SizedBox(height: 8),
        DropdownButtonFormField2<String>(
          value: _selectedLanguageType,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 25, 25, 25),
            ),
          ),
          buttonStyleData: ButtonStyleData(
            width: double.infinity,
            padding: EdgeInsets.zero,
          ),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder()
          ),
          items: languageTypes.map((String entry) => 
            DropdownMenuItem(
              value: entry,
              child: Text(entry)
            )
          ).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedLanguageType = value!;
              _languageIndex = languageTypes.indexOf(_selectedLanguageType);
            });
            databaseManager.updatePreferences(
              UserPreferences(
                authManager.currentUser!.id,
                _languageIndex,
                _summaryIndex,
                true
              )
            );
          },
        ),
      ],
    );
  }

  Widget _createSummaryTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 6,
          children: [
            Icon(
              Icons.format_list_bulleted,
              color: Colors.white,
              size: 24,
            ),
            Text(
              "Summary Type",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
        SizedBox(height: 8),
        DropdownButtonFormField2<String>(
          value: _selectedSummaryType,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 25, 25, 25),
            ),
          ),
          buttonStyleData: ButtonStyleData(
            width: double.infinity,
            padding: EdgeInsets.zero,
          ),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder()
          ),
          items: summaryTypes.map((String entry) => 
            DropdownMenuItem<String>(
              value: entry,
              child: Text(entry),
            )
          ).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedSummaryType = value!;
              _summaryIndex = summaryTypes.indexOf(_selectedSummaryType);
            });
            databaseManager.updatePreferences(
              UserPreferences(
                authManager.currentUser!.id,
                _languageIndex,
                _summaryIndex,
                true
              )
            );
          },
        ),
      ],
    );
  }

  Widget _createPublicSummaryToggle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Public Summaries",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          )
        ),
      ]
    );
  }

  Widget _createFormField({
    required String label,
    required TextEditingController controller,
    required Function validator
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        return validator(value);
      },
      decoration: defaultDecoration(label: label),
      style: TextStyle(
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}

class SummaryCard extends StatefulWidget {
  const SummaryCard({super.key});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: realtimeManager,
      builder: (context, child) {
        final summaries = realtimeManager.summaries;
        if (summaries.isEmpty) {
          return noSummaries();
        }

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SummaryPage(content: {
                "summary": summaries.first.summaryUrl,
                "metadata": {
                  "thumbnail": summaries.first.thumbnailUrl,
                  "title": summaries.first.videoTitle,
                  "author": summaries.first.videoAuthor,
                  "length": summaries.first.videoLength
                }
              }))
            );
          },
          child: summaryCard(summary: summaries.first),
        );
      },
    );
  }
}