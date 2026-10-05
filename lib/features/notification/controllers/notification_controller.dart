import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_model.dart';
import 'package:stackfood_multivendor/features/notification/domain/service/notification_service_interface.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationServiceInterface notificationServiceInterface;
  NotificationController({required this.notificationServiceInterface});

  List<NotificationModel>? _notificationList;
  List<NotificationModel>? get notificationList => _notificationList;

  bool _hasNotification = false;
  bool get hasNotification => _hasNotification;

  Set<int> _seenNotificationIds = {};

  int _unseenCount = 0;
  int get unseenCount => _unseenCount;

  Future<void> getNotificationList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_notificationList == null || reload || fromRecall) {
      _notificationList = null;

      List<NotificationModel>? notificationList;
      if(dataSource == DataSourceEnum.local) {
        notificationList = await notificationServiceInterface.getList(source: DataSourceEnum.local);
        _prepareNotificationList(notificationList);
        getNotificationList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        notificationList = await notificationServiceInterface.getList(source: DataSourceEnum.client);
        _prepareNotificationList(notificationList);
      }
    }
  }

  void _prepareNotificationList(List<NotificationModel>? notificationList) {
    if(notificationList != null) {
      _notificationList = notificationList;
      _seenNotificationIds = notificationServiceInterface.getNotificationIdList().toSet();
      _resolveUnseenCount();
    }
    update();
  }

  void _resolveUnseenCount() {
    _unseenCount = _notificationList?.where((notification) => !_seenNotificationIds.contains(notification.id)).length ?? 0;
    _hasNotification = _unseenCount > 0;
  }

  bool isSeen(int? id) => _seenNotificationIds.contains(id);

  void saveSeenNotificationCount(int count) {
    notificationServiceInterface.saveSeenNotificationCount(count);
  }

  int? getSeenNotificationCount() {
    return notificationServiceInterface.getSeenNotificationCount();
  }

  void clearNotification() {
    _notificationList = null;
  }

  void addSeenNotificationId(int id) {
    if(!_seenNotificationIds.add(id)) {
      return;
    }
    notificationServiceInterface.addSeenNotificationIdList(_seenNotificationIds.toList());
    _resolveUnseenCount();
    update();
  }

  void markAllAsSeen() {
    final List<int> ids = _notificationList?.map((notification) => notification.id).whereType<int>().toList() ?? [];
    if(ids.isEmpty) {
      return;
    }
    _seenNotificationIds.addAll(ids);
    notificationServiceInterface.addSeenNotificationIdList(_seenNotificationIds.toList());
    _resolveUnseenCount();
    update();
  }

  List<int>? getSeenNotificationIdList() {
    return notificationServiceInterface.getNotificationIdList();
  }

}