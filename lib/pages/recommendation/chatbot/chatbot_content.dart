import 'package:flareline/pages/recommendation/recommendation_page.dart';
import 'package:flareline/services/lanugage_extension.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
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
  String _selectedModel = 'Gemini';
  bool _showQuickChat = true;
  bool _conversationStarted = false;

  final List<String> _availableModels = ['Gemini', 'GPT-4', 'Claude', 'Llama'];

  // Initial quick response options
  final List<Map<String, dynamic>> _quickOptions = [
    {
      'icon': Icons.eco,
      'title': 'Soil Health',
      'message': 'Tell me about soil health and pH levels',
      'color': Colors.brown,
    },
    {
      'icon': Icons.agriculture,
      'title': 'Crop Selection',
      'message': 'What crops should I grow in my region?',
      'color': Colors.green,
    },
    {
      'icon': Icons.bug_report,
      'title': 'Pest Control',
      'message': 'How do I control pests organically?',
      'color': Colors.red,
    },
    {
      'icon': Icons.water_drop,
      'title': 'Irrigation',
      'message': 'What are the best irrigation practices?',
      'color': Colors.blue,
    },
    {
      'icon': Icons.scatter_plot,
      'title': 'Fertilizers',
      'message': 'Which fertilizers should I use for my crops?',
      'color': Colors.orange,
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Planting Season',
      'message': 'When is the best time to plant crops?',
      'color': Colors.purple,
    },
    {
      'icon': Icons.healing,
      'title': 'Plant Disease',
      'message': 'How do I identify and treat plant diseases?',
      'color': Colors.teal,
    },
    {
      'icon': Icons.wb_sunny,
      'title': 'Weather Impact',
      'message': 'How does weather affect crop growth?',
      'color': Colors.amber,
    },
  ];

  @override
  void initState() {
    super.initState();
    _chatbotModel = ChatbotModel();
    _chatbotModel.addListener(_onChatbotModelChanged);
  }

  @override
  void dispose() {
    _chatbotModel.removeListener(_onChatbotModelChanged);
    super.dispose();
  }

  // Simplified listener - suggestions come directly from the model now
  void _onChatbotModelChanged() {
    if (_chatbotModel.messages.length > 1 && !_conversationStarted) {
      setState(() {
        _conversationStarted = true;
        _showQuickChat = false;
      });
    }
  }

  void hideQuickChat() {
    setState(() {
      _showQuickChat = false;
    });
  }

  void showQuickChat() {
    setState(() {
      _showQuickChat = true;
    });
  }

  void toggleQuickChat() {
    setState(() {
      _showQuickChat = !_showQuickChat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isTablet = MediaQuery.of(context).size.width < 900;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _chatbotModel,
      child: SingleChildScrollView(
        child: Container(
          height: screenHeight - 100,
          padding: EdgeInsets.all(isMobile ? 0.0 : 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 1200,
                minHeight: screenHeight - 132,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildResponsiveHeader(isMobile, isTablet, isDarkMode),
                  const SizedBox(height: 16),
                  if (!_conversationStarted)
                    _buildQuickOptionsSection(isMobile, isDarkMode),
                  if (!_conversationStarted) const SizedBox(height: 16),
                  Expanded(
                    child: _buildChatInterfaceCard(isMobile, isDarkMode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSuggestions(bool isMobile, bool isDarkMode) {
    return Consumer<ChatbotModel>(
      builder: (context, model, child) {
        final suggestions = model.latestSuggestions;

        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        // Use horizontal scroll on mobile, wrap on web/desktop
        final bool useHorizontalScroll = isMobile || suggestions.length <= 3;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: useHorizontalScroll
              ? _buildHorizontalScrollSuggestions(suggestions, isDarkMode)
              : _buildWrapSuggestions(suggestions, isDarkMode),
        );
      },
    );
  }

  Widget _buildHorizontalScrollSuggestions(
      List<String> suggestions, bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildSuggestionChip(suggestion, isDarkMode),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWrapSuggestions(List<String> suggestions, bool isDarkMode) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: suggestions.map((suggestion) {
        return _buildSuggestionChip(suggestion, isDarkMode);
      }).toList(),
    );
  }

  Widget _buildSuggestionChip(String suggestion, bool isDarkMode) {
    return InkWell(
      onTap: () => _handleSuggestionTap(suggestion),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color:
              isDarkMode ? Theme.of(context).cardTheme.color : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              suggestion,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSuggestionTap(String suggestion) {
    _chatbotModel.addUserMessage(suggestion);
    _chatbotModel.getBotResponse(suggestion,
        useStreaming: _chatbotModel.useStreaming);
  }

  Widget _buildQuickOptionsSection(bool isMobile, bool isDarkMode) {
    return Consumer<ChatbotModel>(
      builder: (context, model, child) {
        return Card(
          elevation: 2,
          color: isDarkMode ? FlarelineColors.darkerBackground : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on,
                            color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Topics',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.grey[300]
                                        : Theme.of(context).cardTheme.color,
                                  ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: AnimatedRotation(
                        turns: _showQuickChat ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_less,
                          size: 24,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      onPressed: toggleQuickChat,
                      tooltip: _showQuickChat
                          ? 'Hide Quick Topics'
                          : 'Show Quick Topics',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showQuickChat
                      ? Column(
                          children: [
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 2 : 4,
                                childAspectRatio: isMobile ? 2.5 : 4.0,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _quickOptions.length,
                              itemBuilder: (context, index) {
                                final option = _quickOptions[index];
                                return _buildQuickOptionCard(
                                    option, isMobile, isDarkMode);
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickOptionCard(
      Map<String, dynamic> option, bool isMobile, bool isDarkMode) {
    return InkWell(
      onTap: () => _handleQuickOption(option['message']),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color:
              isDarkMode ? Theme.of(context).cardTheme.color : Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option['icon'],
              color: option['color'],
              size: isMobile ? 20 : 24,
            ),
            SizedBox(height: isMobile ? 4 : 6),
            Flexible(
              child: Text(
                option['title'],
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickOption(String message) {
    _chatbotModel.addUserMessage(message);
    _chatbotModel.getBotResponse(message,
        useStreaming: _chatbotModel.useStreaming);
  }

  Widget _buildResponsiveHeader(bool isMobile, bool isTablet, bool isDarkMode) {
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
        color: Theme.of(context).cardTheme.color,
        items: [
          PopupMenuItem(
            value: 'back',
            child: ListTile(
              title: Text(context.translate('Crop Recommendations')),
            ),
          ),
          PopupMenuItem(
            value: 'suitability',
            child: ListTile(
              title: Text(context.translate('Crop Suitability')),
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

    if (!isMobile && !isTablet) {
      return Consumer<ChatbotModel>(
        builder: (context, model, child) {
          return Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      height: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Agriculture Assistant',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Tooltip(
                              message: '',
                              child: IconButton(
                                key: _navigationMenuKey,
                                icon: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(-1.0, 1.0),
                                  child: Icon(
                                    Icons.keyboard_return,
                                    size: 0,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey,
                                  ),
                                ),
                                onPressed: _showNavigationMenu,
                                splashRadius: 1,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                Row(
                  children: [
                    Tooltip(
                      message: 'Clear Chat',
                      child: IconButton(
                        onPressed: () => _showClearChatDialog(),
                        icon: Icon(Icons.refresh,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey),
                        splashRadius: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: context.translate('Select AI Model'),
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
                                mainAxisSize: MainAxisSize.min,
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
                            border: Border.all(
                                color: isDarkMode
                                    ? Colors.grey[600]!
                                    : Colors.grey[500]!,
                                width: 2),
                            color: isDarkMode
                                ? Theme.of(context).cardTheme.color
                                : Colors.white,
                          ),
                          child: Icon(
                            Icons.memory,
                            size: 30,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    return Consumer<ChatbotModel>(
      builder: (context, model, child) {
        return Container(
          height: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.translate('Agriculture Assistant'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 24 : 28,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: 'Navigation Options',
                    child: IconButton(
                      key: _navigationMenuKey,
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(-1.0, 1.0),
                        child: Icon(
                          Icons.keyboard_return,
                          size: 0,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
                      onPressed: _showNavigationMenu,
                      splashRadius: 1,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Row(
                    children: [
                      Tooltip(
                        message: 'Clear Chat',
                        child: IconButton(
                          onPressed: () => _showClearChatDialog(),
                          icon: Icon(Icons.refresh,
                              color:
                                  isDarkMode ? Colors.grey[400] : Colors.grey,
                              size: 18),
                          splashRadius: 16,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: context.translate('Select AI Model'),
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
                                  mainAxisSize: MainAxisSize.min,
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
                              border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey[600]!
                                      : Colors.grey[500]!,
                                  width: 1),
                              color: isDarkMode
                                  ? Theme.of(context).cardTheme.color
                                  : Colors.white,
                            ),
                            child: Icon(
                              Icons.memory,
                              size: 15,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              isDarkMode ? FlarelineColors.darkerBackground : Colors.white,
          title: Text('Clear Chat',
              style:
                  TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          content: Text('Are you sure you want to clear all messages?',
              style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _chatbotModel.clearChat();
                setState(() {
                  _conversationStarted = false;
                  _showQuickChat = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatInterfaceCard(bool isMobile, bool isDarkMode) {
    return Consumer<ChatbotModel>(
      builder: (context, model, child) {
        return Card(
          color: isDarkMode ? FlarelineColors.darkerBackground : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 60,
                  child: Row(
                    children: [
                      Flexible(
                        flex: isMobile ? 1 : 2,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Theme.of(context).cardTheme.color
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.memory,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Model: ${model.currentModel}',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 3,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Theme.of(context).cardTheme.color
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _conversationStarted
                                        ? 'Tap suggestions below to continue'
                                        : 'Try the quick topics above or ask anything!',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Chat(
                          messages: model.messages,
                          onSendPressed: model.handleSendPressed,
                          user: model.user,
                          showUserAvatars: true,
                          showUserNames: true,
                          theme: DefaultChatTheme(
                            backgroundColor: isDarkMode
                                ? FlarelineColors.darkerBackground
                                : Colors.white,
                            primaryColor: isDarkMode
                                ? Theme.of(context).cardTheme.color!
                                : Colors.grey.shade200,
                            secondaryColor: isDarkMode
                                ? Theme.of(context).cardTheme.color!
                                : Colors.grey.shade200,
                            inputBackgroundColor: isDarkMode
                                ? Theme.of(context).cardTheme.color!
                                : Colors.grey.shade200,
                            inputTextColor:
                                isDarkMode ? Colors.white : Colors.black87,
                            inputBorderRadius: BorderRadius.circular(24),
                            inputMargin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            userAvatarNameColors: [
                              isDarkMode ? Colors.grey[300]! : Colors.black
                            ],
                            receivedMessageBodyTextStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[800],
                              fontSize: isMobile ? 14 : 16,
                              height: 1.4,
                            ),
                            sentMessageBodyTextStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[800],
                              fontSize: 14,
                              height: 1.4,
                            ),
                            receivedMessageBodyLinkTextStyle: TextStyle(
                              color:
                                  isDarkMode ? Colors.blue[200]! : Colors.blue,
                              fontSize: isMobile ? 14 : 16,
                              height: 1.4,
                            ),
                            sendButtonIcon: Icon(
                              Icons.send,
                              color:
                                  isDarkMode ? Colors.grey[400] : Colors.grey,
                              size: 22,
                            ),
                          ),
                          typingIndicatorOptions: TypingIndicatorOptions(
                            typingUsers: model.isTyping ? [model.bot] : [],
                          ),
                          avatarBuilder: (userId) {
                            final bool isBot = userId == model.bot.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CircleAvatar(
                                backgroundColor: isBot
                                    ? (isDarkMode
                                        ? Theme.of(context).cardTheme.color!
                                        : Colors.grey.shade200)
                                    : (isDarkMode
                                        ? Theme.of(context).cardTheme.color!
                                        : Colors.grey[200]!),
                                child: Icon(
                                  isBot ? Icons.agriculture : Icons.person,
                                  color: isBot
                                      ? (isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey.shade800)
                                      : (isDarkMode
                                          ? Colors.grey.shade200
                                          : Colors.grey.shade800),
                                  size: 20,
                                ),
                                radius: 18,
                              ),
                            );
                          },
                          l10n: ChatL10nEn(
                            inputPlaceholder:
                                'Type your agriculture question...',
                          ),
                        ),
                      ),
                      // Show dynamic suggestions above input field
                      if (_conversationStarted && !model.isTyping)
                        _buildDynamicSuggestions(isMobile, isDarkMode),
                    ],
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
