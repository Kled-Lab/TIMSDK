library tim_ui_kit;

import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

import 'data_services/core/core_services_implements.dart';
export 'data_services/core/core_services_implements.dart';
export 'ui/utils/tui_theme.dart';

// Widgets
export 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_chat.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitProfile/tim_uikit_profile.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitProfile/tim_uikit_operation_item.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitContact/tim_uikit_contact.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitGroup/tim_uikit_group.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitBlackList/tim_uikit_black_list.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitNewContact/tim_uikit_new_contact.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitNewContact/tim_uikit_unread_count.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';

// Enum
export 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
export 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
export 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
export 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
export 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
export 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
export 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
export 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';

// Controller
export 'package:tim_ui_kit/ui/controller/tim_uikit_profile_controller.dart';

class TIMUIKitCore {
  static CoreServicesImpl getInstance() {
    setupServiceLocator();
    return serviceLocator<CoreServicesImpl>();
    // return CoreServicesImpl();
  }

  static V2TIMManager getSDKInstance() {
    return TencentImSDKPlugin.v2TIMManager;
  }
}
