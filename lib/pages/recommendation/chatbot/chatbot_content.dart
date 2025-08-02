import 'package:flareline/pages/recommendation/recommendation_page.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/recommendation/suitability/suitability_page.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'chatbot_model.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  ChatbotContentState createState() => ChatbotContentState();
}

class ChatbotContentState extends State<ChatbotWidget> {
  final GlobalKey _navigationMenuKey = GlobalKey();
  late ChatbotModel _chatbotModel;
  String _selectedModel = 'Gemini'; // Default model

  final List<String> _availableModels = [
    'Gemini',
    'GPT-4',
    'Claude',
    'Llama'
  ]; // Add more models as needed

  @override
  void initState() {
    super.initState();
    _chatbotModel = ChatbotModel();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isTablet = MediaQuery.of(context).size.width < 900;

    return ChangeNotifierProvider.value(
      value: _chatbotModel,
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: isMobile ? double.infinity : 1200),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResponsiveHeader(isMobile, isTablet),
                const SizedBox(height: 24),
                _buildChatInterfaceCard(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(bool isMobile, bool isTablet) {
    void _showNavigationMenu() async {
      final RenderBox? renderBox =
          _navigationMenuKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
      final Size buttonSize = renderBox.size;

      final result = await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          buttonPosition.dx,
          buttonPosition.dy + buttonSize.height,
          buttonPosition.dx + 200,
          buttonPosition.dy + buttonSize.height + 100,
        ),
        items: [
          const PopupMenuItem(
            value: 'back',
            child: ListTile(
              title: Text('Crop Recommendations'),
            ),
          ),
          const PopupMenuItem(
            value: 'suitability',
            child: ListTile(
              title: Text('Crop Suitability'),
            ),
          ),
        ],
      );

      if (result == 'back') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecommendationPage(),
          ),
        );
      } else if (result == 'suitability') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuitabilityPage()),
        );
      }
    }

    void _showModelSelectionMenu() async {
      final RenderBox? renderBox =
          _navigationMenuKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
      final Size buttonSize = renderBox.size;

      final result = await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          buttonPosition.dx,
          buttonPosition.dy + buttonSize.height,
          buttonPosition.dx + 200,
          buttonPosition.dy + buttonSize.height + 200,
        ),
        items: _availableModels
            .map((model) => PopupMenuItem(
                  value: model,
                  child: ListTile(
                    title: Text(model),
                    trailing: _selectedModel == model
                        ? const Icon(Icons.check, size: 16)
                        : null,
                  ),
                ))
            .toList(),
      );

      if (result != null) {
        setState(() {
          _selectedModel = result;
          // Here you would update the chatbot model to use the selected AI
          _chatbotModel.setModel(result);
        });
      }
    }

    if (!isMobile && !isTablet) {
      return Consumer<ChatbotModel>(
        builder: (context, model, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agriculture Assistant',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                          color: const Color.fromARGB(255, 1, 1, 1),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Tooltip(
                    message: 'Navigation Options',
                    child: IconButton(
                      key: _navigationMenuKey,
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(-1.0, 1.0),
                        child: const Icon(
                          Icons.keyboard_return,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: _showNavigationMenu,
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              Tooltip(
                message: 'Select AI Model',
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _selectedModel = value;
                      _chatbotModel.setModel(value);
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return _availableModels.map((String model) {
                      return PopupMenuItem<String>(
                        value: model,
                        child: Row(
                          children: [
                            Text(model),
                            if (_selectedModel == model)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.check, size: 16),
                              ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[500]!, width: 2),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.memory, // AI model icon
                      size: 30,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Consumer<ChatbotModel>(
      builder: (context, model, child) {
        return Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agriculture Assistant',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 24 : 28,
                        color: const Color.fromARGB(255, 1, 1, 1),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: 'Navigation Options',
                      child: IconButton(
                        key: _navigationMenuKey,
                        icon: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..scale(-1.0, 1.0),
                          child: const Icon(
                            Icons.keyboard_return,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                        onPressed: _showNavigationMenu,
                        splashRadius: 16,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Tooltip(
                      message: 'Select AI Model',
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            _selectedModel = value;
                            _chatbotModel.setModel(value);
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return _availableModels.map((String model) {
                            return PopupMenuItem<String>(
                              value: model,
                              child: Row(
                                children: [
                                  Text(model),
                                  if (_selectedModel == model)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(Icons.check, size: 16),
                                    ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.grey[500]!, width: 1),
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.memory, // AI model icon
                            size: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatInterfaceCard(bool isMobile) {
    return Consumer<ChatbotModel>(
      builder: (context, model, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Add this to your _buildChatInterfaceCard method, in the Row with model selection:

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Model: ${model.currentModel}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // // Add streaming toggle
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 8, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey[50],
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Icon(
                    //         model.useStreaming ? Icons.stream : Icons.chat,
                    //         color: Colors.grey[600],
                    //         size: 16,
                    //       ),
                    //       const SizedBox(width: 4),
                    //       Text(
                    //         model.useStreaming ? 'Streaming' : 'Regular',
                    //         style: TextStyle(
                    //           color: Colors.grey[600],
                    //           fontSize: 10,
                    //         ),
                    //       ),
                    //       const SizedBox(width: 4),
                    //       Switch(
                    //         value: model.useStreaming,
                    //         onChanged: (value) {
                    //           model.toggleStreamingMode(value);
                    //         },
                    //         materialTapTargetSize:
                    //             MaterialTapTargetSize.shrinkWrap,
                    //         // visualDensity: VisualDensity.compact,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    if (!isMobile)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Try asking about soil, crops, pests, etc.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height:
                      isMobile ? MediaQuery.of(context).size.height * 0.6 : 400,
                  child: Chat(
                    messages: model.messages,
                    onSendPressed: model.handleSendPressed,
                    user: model.user,
                    showUserAvatars: true,
                    showUserNames: true,
                    theme: DefaultChatTheme(
                      primaryColor: Colors.grey.shade200,
                      secondaryColor: Colors.grey.shade200,
                      inputBackgroundColor: Colors.grey.shade200,
                      inputTextColor: Colors.black87,
                      inputBorderRadius: BorderRadius.circular(24),
                      inputMargin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      userAvatarNameColors: [
                        const Color.fromARGB(255, 7, 7, 7)!
                      ],
                      receivedMessageBodyTextStyle: TextStyle(
                        color: Colors.grey[800],
                        fontSize: isMobile ? 14 : 16,
                        height: 1.4,
                      ),
                      sentMessageBodyTextStyle: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      sendButtonIcon: const Icon(
                        Icons.send,
                        color: Colors.grey,
                        size: 22,
                      ),
                    ),
                    typingIndicatorOptions: TypingIndicatorOptions(
                      typingUsers: model.isTyping ? [model.bot] : [],
                    ),
                    avatarBuilder: (userId) {
                      final bool isBot = userId == model.bot.id;
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 8.0), // Add padding to the right
                        child: CircleAvatar(
                          backgroundColor:
                              isBot ? Colors.green[100] : Colors.blue[100],
                          child: Icon(
                            isBot ? Icons.agriculture : Icons.person,
                            color: isBot ? Colors.green[800] : Colors.blue[800],
                            size: 20,
                          ),
                          radius: 18,
                        ),
                      );
                    },
                    l10n: const ChatL10nEn(
                      inputPlaceholder: '...',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
