import 'dart:math';

import 'package:ch_db_admin/shared/notification_util.dart';
import 'package:ch_db_admin/src/Members/presentation/ui/members_view.dart';
import 'package:ch_db_admin/src/attendance/presentation/ui/attendance_view.dart';
import 'package:ch_db_admin/src/main_view/controller/main_view_controller.dart';
import 'package:ch_db_admin/src/main_view/presentation/side_menu_view.dart';
import 'package:ch_db_admin/src/Members/notifications/presentation/ui/notifications_view.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  void update() {
    setState(() {});
  }

  AppUpdateInfo? _updateInfo;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });

      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        InAppUpdate.startFlexibleUpdate().then(
          (result) => InAppUpdate.completeFlexibleUpdate(),
        );
      }
    }).catchError((e) {
      NotificationUtil.showError(context, e.toString());
    });
  }

  @override
  void initState() {
    context.read<MainViewController>().init(setState: update, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    var controller = context.read<MainViewController>();
    var watchController = context.watch<MainViewController>();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastOutSlowIn,
                height: MediaQuery.sizeOf(context).height,
                width: 288,
                left: watchController.isMenuOpened ? 0 : -288,
                child: const SideMenuView()),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                //rotate 30 degress
                ..rotateY(controller.animation.value -
                    30 * controller.animation.value * pi / 180),
              child: Transform.translate(
                offset: Offset(controller.animation.value * 265, 0),
                child: Transform.scale(
                    scale: controller.scaleAnimation.value,
                    child: ClipRRect(
                        borderRadius: controller.isMenuOpened
                            ? BorderRadius.circular(15)
                            : BorderRadius.zero,
                        child: const HomeBodyView())),
              ),
            ),
            AnimatedPositioned(
                left: watchController.isMenuOpened ? screenWidth * .8 : 20,
                top: 8,
                duration: const Duration(milliseconds: 250),
                child: GestureDetector(
                  onTap: () {
                    controller.toggleMenuOpened();
                  },
                  child: CircleAvatar(
                    child: watchController.isMenuOpened == true
                        ? const Icon(Icons.close)
                        : const Icon(Icons.menu),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class HomeBodyView extends StatefulWidget {
  const HomeBodyView({super.key});

  @override
  State<HomeBodyView> createState() => _HomeBodyViewState();
}

class _HomeBodyViewState extends State<HomeBodyView> {
  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<MainViewController>().initIt(setState: update);
  }

  var views = const [
    // DashboardView(),
    MembersView(),
    AttendanceView(),
    // EventsView(),
    NotificationsView()
  ];
  @override
  Widget build(BuildContext context) {
    var controller = context.read<MainViewController>();
    return PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: views.length,
        controller: controller.pageController,
        itemBuilder: (context, index) => views[index]);
  }
}
