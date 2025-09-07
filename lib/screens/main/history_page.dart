import 'package:flutter/material.dart';
import 'package:vidsummarizer/core/components.dart';
import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/model/user_summary.dart';
import 'package:vidsummarizer/screens/main/summary_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _summaryNameController = TextEditingController();

  bool _deleteMode = false;
  String _summaryName = "";
  final Set<String> _selectedSummaries = {};

  Future<bool?> _deletionDialog() async {
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
                "Delete Summary",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "You will no longer be able to access any of this information or its related content",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                splashColor: Colors.transparent,
                child: defaultButton(label: "Proceed with deletion", isDeletion: true)
              )
            ],
          ),
        ),
      )
    );
  }

  Future<void> _deleteSummary() async {
    bool? deleteSummaries = await _deletionDialog();

    deleteSummaries = deleteSummaries == null ? false : true;
    if (deleteSummaries) {
      try {
        for (final id in _selectedSummaries) {
          databaseManager.deleteSummary(id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            defaultSnackBar("Successfully deleted your summaries")
          );
        }
      }
      catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            defaultSnackBar("There was an error deleting your summary. Try again later")
          );
        }
      }
    }
    setState(() {
      _selectedSummaries.clear();
      _deleteMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: historyBar(
        backTap: () => Navigator.of(context).pop(),
        deleteTap: () => {
          if (_deleteMode) {
            _deleteSummary()
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              defaultSnackBar("You haven't selected any summaries to delete")
            )
          }
        },
        deleteMode: _deleteMode
      ),
      body: _createBody(),
    );
  }

  Widget _createBody() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _createFormField(),
          const SizedBox(height: 18),
          _createSummaryList(),
        ],
      ),
    );
  }

  Widget _createFormField() {
    return TextFormField(
      controller: _summaryNameController,
      decoration: defaultDecoration(label: "Summary Name"),
      style: TextStyle(
        color: Colors.white,
      ),
      onChanged: (String value) {
        setState(() {
          _summaryName = value.toLowerCase();
        });
      },
      cursorColor: Colors.white,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Widget _createSummaryList() {
    return Expanded(
      child: AnimatedBuilder(
        animation: realtimeManager,
        builder: (context, index) {
          final summaries = realtimeManager.summaries;
          if (summaries.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 32),
              child: noSummaries(),
            );
          }

          List<UserSummary> filtered = [];
          for (final summary in summaries) {
            if (summary.summaryName!.toLowerCase().contains(_summaryName)) {
              filtered.add(summary);
            }
          }

          return ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => SummaryPage(content: {
                            "summary": filtered[index].summaryUrl,
                            "metadata": {
                              "thumbnail": filtered[index].thumbnailUrl,
                              "title": filtered[index].videoTitle,
                              "author": filtered[index].videoAuthor,
                              "length": filtered[index].videoLength
                            }
                          })
                        ));
                      },
                      child: summaryCard(summary: filtered[index]),
                    )
                  ),
                  Checkbox.adaptive(
                    checkColor: Colors.white,
                    activeColor: Colors.black,
                    value: _selectedSummaries.contains(summaries[index].summaryId), 
                    onChanged: (selected) {
                      final summaryId = summaries[index].summaryId!;
                      setState(() {
                        if (selected ?? false) {
                          _selectedSummaries.add(summaryId);
                          _deleteMode = true;
                        }
                        else {
                          _selectedSummaries.remove(summaryId);
                          if (_selectedSummaries.isEmpty) {
                            _deleteMode = false;
                          }
                        }
                      });
                    },
                  )
                ],
              );
            }
          );
        }
      )
    );
  }
}