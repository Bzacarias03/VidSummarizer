import 'package:dart_openai/dart_openai.dart';

import 'package:vidsummarizer/core/constants.dart';

class OpenAIClient {

  OpenAIClient() {
    _setupClient();
  }

  Future<void> _setupClient() async {
    OpenAI.requestsTimeOut = Duration(seconds: 60);
  }

  Future<String> generateSummary({
    required String captions,
    required String languageType,
    required String summaryType,
  }) async {
    String prompt = createPrompt(
      captions: captions,
      summaryType: summaryType,
      languageType: languageType
    );
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
      ],
      role: OpenAIChatMessageRole.user,
    );

    String summary;
    try {
      OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4.1-nano",
        messages: [
          userMessage
        ],
        seed: 6,
        temperature: 0.5,
        maxTokens: 300,
      );
      
      if (chatCompletion.choices.first.message.content == null) {
        throw Exception("Failed to generate summary");
      }
      summary = chatCompletion.choices.first.message.content!.first.text!;
    }
    catch (error) {
      rethrow;
    }

    return summary;
  }
}