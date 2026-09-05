import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';

class ChatLocalDataSource {
  const ChatLocalDataSource();

  // CHAT LIST

  Future<List<Chat>> getChats() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      Chat(
        id: '1',
        personName: 'Meron Tesfaye',
        initials: 'MT',
        role: 'Parent',
        lastMessage: 'Thank you, teacher. I really appreciate it.',
        lastMessageTime: '10:32 AM',
        unreadCount: 2,
        isOnline: true,
      ),

      Chat(
        id: '2',
        personName: 'Abebe Kebede',
        initials: 'AK',
        role: 'Parent',
        lastMessage: 'How is Dawit doing in class today?',
        lastMessageTime: '9:45 AM',
        unreadCount: 1,
        isOnline: true,
      ),

      Chat(
        id: '3',
        personName: 'Liya Solomon',
        initials: 'LS',
        role: 'Teacher',
        lastMessage: 'I will send the report this afternoon.',
        lastMessageTime: 'Yesterday',
        unreadCount: 0,
        isOnline: false,
      ),

      Chat(
        id: '4',
        personName: 'Mekonnen Getachew',
        initials: 'MG',
        role: 'Parent',
        lastMessage: 'Can we discuss his progress?',
        lastMessageTime: 'Yesterday',
        unreadCount: 3,
        isOnline: true,
      ),

      Chat(
        id: '5',
        personName: 'Bethel Alemu',
        initials: 'BA',
        role: 'Advisor',
        lastMessage: 'The student meeting is scheduled for Friday.',
        lastMessageTime: 'Monday',
        unreadCount: 0,
        isOnline: false,
      ),

      Chat(
        id: '6',
        personName: 'Hana Girma',
        initials: 'HG',
        role: 'Parent',
        lastMessage: 'Okay, I will check with her tonight.',
        lastMessageTime: 'Monday',
        unreadCount: 0,
        isOnline: true,
      ),
    ];
  }

  // MESSAGES

  Future<List<Message>> getMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    switch (chatId) {
      case '1':
        return const [
          Message(
            id: '1',
            chatId: '1',
            text: 'Good morning teacher.',
            isMine: false,
            time: '10:20 AM',
          ),
          Message(
            id: '2',
            chatId: '1',
            text: 'Good morning Meron. How are you?',
            isMine: true,
            time: '10:22 AM',
          ),
          Message(
            id: '3',
            chatId: '1',
            text: 'I am doing well, thank you.',
            isMine: false,
            time: '10:24 AM',
          ),
          Message(
            id: '4',
            chatId: '1',
            text: 'I wanted to ask about Abel\'s homework.',
            isMine: false,
            time: '10:25 AM',
          ),
          Message(
            id: '5',
            chatId: '1',
            text: 'He completed it this morning.',
            isMine: true,
            time: '10:28 AM',
          ),
          Message(
            id: '6',
            chatId: '1',
            text: 'Thank you, teacher. I really appreciate it.',
            isMine: false,
            time: '10:32 AM',
          ),
        ];

      case '2':
        return const [
          Message(
            id: '7',
            chatId: '2',
            text: 'Hello teacher.',
            isMine: false,
            time: '9:35 AM',
          ),
          Message(
            id: '8',
            chatId: '2',
            text: 'Hello Abebe, good morning.',
            isMine: true,
            time: '9:37 AM',
          ),
          Message(
            id: '9',
            chatId: '2',
            text: 'How is Dawit doing in class today?',
            isMine: false,
            time: '9:45 AM',
          ),
        ];

      case '3':
        return const [
          Message(
            id: '10',
            chatId: '3',
            text: 'Did you finish the student report?',
            isMine: true,
            time: 'Yesterday',
          ),
          Message(
            id: '11',
            chatId: '3',
            text: 'Yes, I have almost finished it.',
            isMine: false,
            time: 'Yesterday',
          ),
          Message(
            id: '12',
            chatId: '3',
            text: 'I will send the report this afternoon.',
            isMine: false,
            time: 'Yesterday',
          ),
        ];

      case '4':
        return const [
          Message(
            id: '13',
            chatId: '4',
            text: 'Hello teacher.',
            isMine: false,
            time: 'Yesterday',
          ),
          Message(
            id: '14',
            chatId: '4',
            text: 'Hello Mekonnen.',
            isMine: true,
            time: 'Yesterday',
          ),
          Message(
            id: '15',
            chatId: '4',
            text: 'Can we discuss his progress?',
            isMine: false,
            time: 'Yesterday',
          ),
        ];

      default:
        return const [];
    }
  }
}
