import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/data/datasource/verification_datasource.dart';
import 'package:rajeali_app/data/model/chat_room_model.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  ChatController({required AppDataSource ds}) : _ds = ds;

  final AppDataSource _ds;
  static const Uuid _uuid = Uuid();

  final TextEditingController messageCtrl = TextEditingController();
  final Rxn<ChatRoomModel> activeRoom = Rxn<ChatRoomModel>();
  final RxList<ChatRoomModel> myRooms = <ChatRoomModel>[].obs;

  void loadRoomsForUser(String userId) {
    myRooms.assignAll(_ds.chatRoomsForUser(userId));
  }

  void openRoom(String roomId) {
    activeRoom.value = _ds.findChatRoomById(roomId);
  }

  void sendMessage(String senderUserId) {
    final ChatRoomModel? room = activeRoom.value;
    final String text = messageCtrl.text.trim();
    if (room == null || text.isEmpty) return;

    final ChatMessageModel msg = ChatMessageModel(
      messageId: _uuid.v4(),
      roomId: room.roomId,
      senderUserId: senderUserId,
      message: text,
      createdAt: DateTime.now(),
    );
    _ds.addMessage(msg);
    activeRoom.value = _ds.findChatRoomById(room.roomId);
    messageCtrl.clear();
  }

  @override
  void onClose() {
    messageCtrl.dispose();
    super.onClose();
  }
}

