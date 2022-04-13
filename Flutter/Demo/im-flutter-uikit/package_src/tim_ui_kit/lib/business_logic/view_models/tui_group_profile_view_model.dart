import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TUIGroupProfileViewModel extends ChangeNotifier {
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  final CoreServicesImpl _coreServices = serviceLocator<CoreServicesImpl>();
  final ConversationService _conversationService =
      serviceLocator<ConversationService>();
  final MessageService _messageService = serviceLocator<MessageService>();
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();

  V2TimGroupInfo? _groupInfo;
  String _groupMemberListSeq = "0";
  List<V2TimGroupMemberFullInfo?>? _groupMemberList = [];
  List<V2TimFriendInfo>? _contactList = [];
  String _groupID = "";
  bool? isDisturb;
  V2TimConversation? conversation;

  V2TimGroupInfo? get groupInfo {
    return _groupInfo;
  }

  List<V2TimFriendInfo>? get contactList {
    return _contactList;
  }

  List<V2TimGroupMemberFullInfo?>? get groupMemberList {
    return _groupMemberList;
  }

  loadData(String groupID) {
    _groupID = groupID;
    _loadGroupInfo(groupID);
    // count只有web时有效
    _loadGroupMemberList(count: 50, groupID: groupID);
    _loadContactList();
    _loadConversation();
  }

  _loadConversation() async {
    conversation = await _conversationService.getConversation(
        conversationID: "group_$_groupID");
    isDisturb = conversation?.recvOpt != 0;
  }

  _loadGroupInfo(String groupID) async {
    final groupInfo =
        await _groupServices.getGroupsInfo(groupIDList: [groupID]);
    if (groupInfo != null) {
      final groupRes = groupInfo.first;
      if (groupRes.resultCode == 0) {
        _groupInfo = groupRes.groupInfo;
      }
    }
    notifyListeners();
  }

  _loadContactList() async {
    final res = await _friendshipServices.getFriendList();
    _contactList = res;
  }

  // TODO 这个count要注意：只在web使用，客户端上传入无效
  _loadGroupMemberList({required String groupID, int count = 50}) async {
    final groupMemberListRes = await _groupServices.getGroupMemberList(
        groupID: groupID,
        filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
        count: count,
        nextSeq: _groupMemberListSeq);
    if (groupMemberListRes != null) {
      final groupMemberList = groupMemberListRes.memberInfoList ?? [];
      _groupMemberList = [...?_groupMemberList, ...groupMemberList];
      _groupMemberListSeq = groupMemberListRes.nextSeq ?? "0";
      notifyListeners();
    }
  }

// TODO 这个count要注意：只在web使用，客户端上传入无效
  _reloadGroupMemberList({required String groupID, int count = 50}) async {
    final groupMemberListRes = await _groupServices.getGroupMemberList(
        groupID: groupID,
        filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
        count: count,
        nextSeq: _groupMemberListSeq);
    if (groupMemberListRes != null) {
      final groupMemberList = groupMemberListRes.memberInfoList ?? [];
      _groupMemberList = groupMemberList;
      _groupMemberListSeq = groupMemberListRes.nextSeq ?? "0";
      notifyListeners();
    }
  }

  loadMoreData({required String groupID, int count = 50}) {
    if (_groupMemberListSeq != "0") {
      _loadGroupMemberList(groupID: groupID, count: count);
    }
  }

  setGroupNotification(String notification) async {
    if (_groupInfo != null) {
      _groupInfo?.notification = notification;
      final response = await _groupServices.setGroupInfo(
          info: V2TimGroupInfo.fromJson({
        "groupID": _groupInfo!.groupID,
        "groupType": _groupInfo!.groupType,
        "notification": notification
      }));
      if (response.code == 0) {
        notifyListeners();
      }
    }
  }

  Future<V2TimCallback?> setMuteAll(bool muteAll) async {
    if (_groupInfo != null) {
      _groupInfo?.isAllMuted = muteAll;
      final response = await _groupServices.setGroupInfo(
          info: V2TimGroupInfo.fromJson({
        "groupID": _groupInfo!.groupID,
        "groupType": _groupInfo!.groupType,
        "isAllMuted": muteAll
      }));
      return response;
    }
    return null;
  }

  Future<V2TimCallback?> setGroupName(String groupName) async {
    if (_groupInfo != null) {
      String? originalGroupName = _groupInfo?.groupName;
      _groupInfo?.groupName = groupName;
      final response = await _groupServices.setGroupInfo(
          info: V2TimGroupInfo.fromJson({
        "groupID": _groupInfo!.groupID,
        "groupType": _groupInfo!.groupType,
        "groupName": groupName
      }));
      if (response.code != 0) {
        _groupInfo?.groupName = originalGroupName;
      }
      notifyListeners();
      return response;
    }
    return null;
  }

  Future<V2TimCallback?> setGroupAddOpt(int addOpt) async {
    if (_groupInfo != null) {
      int? originalAddopt = _groupInfo?.groupAddOpt;
      _groupInfo?.groupAddOpt = addOpt;
      final response = await _groupServices.setGroupInfo(
          info: V2TimGroupInfo.fromJson({
        "groupID": _groupInfo!.groupID,
        "groupType": _groupInfo!.groupType,
        "groupAddOpt": addOpt
      }));
      if (response.code != 0) {
        _groupInfo?.groupAddOpt = originalAddopt;
      }
      notifyListeners();
      return response;
    }
    return null;
  }

  Future<V2TimCallback?> setGroupIntroduction(String introduction) async {
    if (_groupInfo != null) {
      String? originalIntroduction = _groupInfo?.introduction;
      _groupInfo?.introduction = introduction;
      final response = await _groupServices.setGroupInfo(
          info: V2TimGroupInfo.fromJson({
        "groupID": _groupInfo!.groupID,
        "groupType": _groupInfo!.groupType,
        "introduction": introduction
      }));
      if (response.code != 0) {
        _groupInfo?.introduction = originalIntroduction;
      }
      notifyListeners();
      return response;
    }
    return null;
  }

  Future<V2TimCallback> setMemberToNormal(String userID) async {
    final res = await _groupServices.setGroupMemberRole(
        groupID: _groupID,
        userID: userID,
        role: GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER);
    if (res.code == 0) {
      final targetIndex =
          _groupMemberList!.indexWhere((e) => e!.userID == userID);
      if (targetIndex != -1) {
        final targetElem = _groupMemberList![targetIndex];
        targetElem?.role = GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
        _groupMemberList![targetIndex] = targetElem;
      }
      notifyListeners();
    }
    return res;
  }

  Future<V2TimCallback> setMemberToAdmin(String userID) async {
    final res = await _groupServices.setGroupMemberRole(
        groupID: _groupID,
        userID: userID,
        role: GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_ADMIN);
    if (res.code == 0) {
      final targetIndex =
          _groupMemberList!.indexWhere((e) => e!.userID == userID);
      if (targetIndex != -1) {
        final targetElem = _groupMemberList![targetIndex];
        targetElem?.role = GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
        _groupMemberList![targetIndex] = targetElem;
      }
      notifyListeners();
    }
    return res;
  }

  Future<V2TimCallback?> muteGroupMember(String userID, bool isMute) async {
    const muteTime = 31556926 * 10;
    final res = await _groupServices.muteGroupMember(
        groupID: _groupID, userID: userID, seconds: isMute ? muteTime : 0);
    if (res.code == 0) {
      final targetIndex =
          _groupMemberList!.indexWhere((e) => e!.userID == userID);
      if (targetIndex != -1) {
        final targetElem = _groupMemberList![targetIndex];
        targetElem?.muteUntil = isMute ? muteTime : 0;
        _groupMemberList![targetIndex] = targetElem;
      }
      notifyListeners();
    }
    return null;
  }

  String getSelfNameCard() {
    try {
      final loginUserID = _coreServices.loginUserInfo?.userID;
      String nameCard = "";
      if (_groupMemberList != null) {
        nameCard = groupMemberList!
                .firstWhere((element) => element?.userID == loginUserID)
                ?.nameCard ??
            "";
      }

      return nameCard;
    } catch (err) {
      return "";
    }
  }

  bool canInviteMember() {
    final groupType = _groupInfo?.groupType;
    return groupType == GroupType.Work;
  }

  bool canKickOffMember() {
    final isGroupOwner =
        _groupInfo?.role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER;
    final isAdmin =
        _groupInfo?.role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
    if (_groupInfo?.groupType == GroupType.Work) {
      /// work 群主才能踢人
      return isGroupOwner;
    }

    if (_groupInfo?.groupType == GroupType.Public ||
        _groupInfo?.groupType == GroupType.Meeting) {
      /// public || meeting 群主和管理员可以踢人
      return isGroupOwner || isAdmin;
    }

    return false;
  }

  Future<V2TimCallback?> setNameCard(String nameCard) async {
    final loginUserID = _coreServices.loginUserInfo?.userID;
    if (loginUserID != null) {
      final res = await _groupServices.setGroupMemberInfo(
          groupID: _groupID, userID: loginUserID, nameCard: nameCard);
      if (res.code == 0) {
        final targetIndex = _groupMemberList
            ?.indexWhere((element) => element?.userID == loginUserID);
        if (targetIndex != -1) {
          _groupMemberList![targetIndex!]!.nameCard = nameCard;
          notifyListeners();
        }
      }
      return res;
    }
    return null;
  }

  Future<V2TimCallback> kickOffMember(List<String> userIDs) async {
    final res = await _groupServices.kickGroupMember(
        groupID: _groupID, memberList: userIDs);
    if (res.code == 0) {
      _groupMemberList?.removeWhere((e) => userIDs.contains(e?.userID));
      notifyListeners();
    }
    return res;
  }

  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup(List<String> userIDS) async {
    final res = await _groupServices.inviteUserToGroup(
        groupID: _groupID, userList: userIDS);
    if (res.code == 0) {
      _reloadGroupMemberList(count: 50, groupID: _groupID);
    }
    return res;
  }

  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searcrhGroupMember(
      V2TimGroupMemberSearchParam searchParam) async {
    final res =
        await _groupServices.searchGroupMembers(searchParam: searchParam);

    if (res.code == 0) {}
    return res;
  }

  setMessageDisturb(bool value) async {
    final res = await _messageService.setGroupReceiveMessageOpt(
        groupID: _groupID,
        opt: value
            ? ReceiveMsgOptEnum.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE
            : ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE);
    if (res.code == 0) {
      isDisturb = value;
    }
    notifyListeners();
  }

  pinedConversation(bool isPined) async {
    await _conversationService.pinConversation(
        conversationID: "group_$_groupID", isPinned: isPined);
    conversation?.isPinned = isPined;
    notifyListeners();
  }
}