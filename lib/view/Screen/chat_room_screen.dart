import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';
import 'package:rajeali_app/controller/chat_controller.dart';
import 'package:rajeali_app/data/model/chat_room_model.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String roomId = Get.arguments as String;
    final ChatController ctrl = Get.find<ChatController>();
    final AuthController auth = Get.find<AuthController>();
    final String userId = auth.currentUser.value!.id.toString();

    ctrl.openRoom(roomId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثة الآمنة'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: () => Get.snackbar('إبلاغ', 'تم إرسال البلاغ لمدير النظام'),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Obx(() {
              final ChatRoomModel? room = ctrl.activeRoom.value;
              if (room == null) return const Center(child: Text('خطأ في تحميل المحادثة'));
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: room.messages.length,
                itemBuilder: (BuildContext context, int i) {
                  final ChatMessageModel msg = room.messages[room.messages.length - 1 - i];
                  final bool isMe = msg.senderUserId == userId;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(msg.message),
                          const SizedBox(height: 2),
                          Text(
                            '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          // Message input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: ctrl.messageCtrl,
                      decoration: const InputDecoration(hintText: 'اكتب رسالة...'),
                      onSubmitted: (_) => ctrl.sendMessage(userId),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => ctrl.sendMessage(userId),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

