import 'package:flutter/material.dart';

import 'package:vidsummarizer/core/components.dart';
import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/core/file_processor.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key, required this.content});

  final Map<String, dynamic> content;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final FileProcessor fileProcessor = FileProcessor();

  final TextEditingController _nameController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  bool _canPop = false;
  bool _isSupabase = false;
  bool _isLoading = false;
  String _summary = "";

  Future<void> _checkContent() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.content["metadata"]["thumbnail"].contains("supabase")) {
      setState(() {
        _isSupabase = true;
        _canPop = true;
      });

      _summary = await fileProcessor.getSummaryBody(summaryUrl: widget.content["summary"]);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _checkContent();
    super.initState();
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

  Future<bool?> _saveDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Save your summary",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Summary name",
                style: TextStyle(
                  color: Colors.white
                )
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: _formKey,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter a name for your summary";
                  }
                  return null;
                },
                decoration: defaultDecoration(label: "Name"),
                style: const TextStyle(
                  color: Colors.white
                ),
                cursorColor: Colors.white,
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const SizedBox(height: 14),
              const Text(
                "NOTE: It is encouraged to add a rememberable name as they CANNOT be changed later",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: defaultButton(label: "Save"),
              )
            ],
          ),
        )
      )
    );
  }

  Future<void> _saveSummary() async {
    bool? summarySaved = await _saveDialog();

    summarySaved = summarySaved == null ? false : true;
    if (summarySaved) {
      try {
        _showDialog("Saving your summary");
        Map<String, dynamic> data = {
          "summary": widget.content["summary"],
          "captions": widget.content["captions"],
          "thumbnail": widget.content["metadata"]["thumbnail"],
          "summary_name": _nameController.text.trim(),
          "video_title": widget.content["metadata"]["title"],
          "video_author": widget.content["metadata"]["author"],
          "video_length": widget.content["metadata"]["length"],
        };
        await databaseManager.insertSummary(data);

        _dismissDialog();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            defaultSnackBar("Successfully saved your summary")
          );
        }
      }
      catch (error) {
        _dismissDialog();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            defaultSnackBar("There was an error saving your summary. Try again later")
          );
        }
      }
    }
    setState(() {
      _canPop = summarySaved!;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Stack(
        children: [
          PopScope(
            canPop: _canPop,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: primary,
              appBar: summaryBar(
                backTap: () => _isSupabase ? Navigator.of(context).pop() : _saveSummary(),
                downloadTap: () {},
                copyTap: () {},
                shareTap: () {}
              ),
              body: _createBody(),
            ),
          ),
          Container(
            color: Colors.black54,
            child: Center(
              child: loadingDialog(text: "Loading summary..."),
            ),
          ),
        ]
      );
    }

    return PopScope(
      canPop: _canPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: primary,
        appBar: summaryBar(
          backTap: () => _isSupabase ? Navigator.of(context).pop() : _saveSummary(),
          downloadTap: () {},
          copyTap: () {},
          shareTap: () {}
        ),
        body: _createBody(),
      ),
    );
  }

  Widget _createBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
          strokeWidth: 5,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(24),
      child: ListView(
        children: [
          _createMetadataSection(),
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 12),
          _isSupabase
            ? Text(_summary, style: TextStyle(color: Colors.white))
            : Text(widget.content["summary"], style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _createMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Image.network(
            widget.content["metadata"]["thumbnail"],
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 12),
        Text(
          widget.content["metadata"]["title"],
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18
          )
        ),
        SizedBox(height: 12),
        Text(
          "Creator: ${widget.content["metadata"]["author"]}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          )
        ),
        SizedBox(),
        Text(
          "Length: ${widget.content["metadata"]["length"]} minutes",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          )
        ),
      ],
    );
  }
}