/*This file is part of Medito App.

Medito App is free software: you can redistribute it and/or modify
it under the terms of the Affero GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Medito App is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Affero GNU General Public License for more details.

You should have received a copy of the Affero GNU General Public License
along with Medito App. If not, see <https://www.gnu.org/licenses/>.*/

import 'dart:async';

import 'package:Medito/network/api_response.dart';
import 'package:Medito/network/home/connection_bloc.dart';
import 'package:Medito/network/home/home_bloc.dart';
import 'package:Medito/network/home/home_repo.dart';
import 'package:Medito/network/home/menu_response.dart';
import 'package:Medito/tracking/tracking.dart';
import 'package:Medito/network/user/user_utils.dart';
import 'package:Medito/utils/colors.dart';
import 'package:Medito/utils/navigation.dart';
import 'package:Medito/utils/utils.dart';
import 'package:Medito/widgets/home/courses_row_widget.dart';
import 'package:Medito/widgets/home/daily_message_widget.dart';
import 'package:Medito/widgets/home/home_appbar_widget.dart';
import 'package:Medito/widgets/home/small_shortcuts_row_widget.dart';
import 'package:Medito/widgets/home/stats_widget.dart';
import 'package:Medito/widgets/packs/announcement_banner_widget.dart';
import 'package:Medito/widgets/packs/error_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final _bloc = HomeBloc(repo: HomeRepo());
  final _connectionBloc =
      ConnectionBloc(connectivityChecker: checkConnectivity);
  ConnectivityResult _currentConnectivity;
  final GlobalKey<AnnouncementBannerState> _announceKey = GlobalKey();

  final GlobalKey<SmallShortcutsRowWidgetState> _shortcutKey = GlobalKey();

  final GlobalKey<CoursesRowWidgetState> _coursesKey = GlobalKey();

  final GlobalKey<DailyMessageWidgetState> _dailyMessageKey = GlobalKey();

  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    _observeNetwork();
    _connectionBloc.checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () {
            return _refresh();
          },
          child: StreamBuilder<bool>(
              stream: _connectionBloc.connectionStreamController.stream,
              initialData: true,
              builder: (context, connectionSnapshot) {
                print(
                    'connection snapshot ${connectionSnapshot.data}');
                if (connectionSnapshot.hasData && !connectionSnapshot.data) {
                  return _buildErrorPacksWidget();
                } else {
                  return ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      HomeAppBar(bloc: _bloc),
                      AnnouncementBanner(key: _announceKey),
                      SmallShortcutsRowWidget(
                        key: _shortcutKey,
                        onTap: (type, id) => _navigate(
                            type, id, context, Tracking.SHORTCUT_TAPPED),
                      ),
                      CoursesRowWidget(
                          key: _coursesKey,
                          onTap: (type, id) => _navigate(
                              type, id, context, Tracking.COURSE_TAPPED)),
                      DailyMessageWidget(key: _dailyMessageKey),
                      StatsWidget(),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }

  Column _buildErrorPacksWidget() => Column(
        children: [
          HomeAppBar(bloc: _bloc),
          Expanded(child: ErrorPacksWidget(onPressed: () => _refresh())),
        ],
      );

  Future<void> _navigate(type, id, BuildContext context, String origin) {
    Tracking.trackEvent({
      Tracking.TYPE: origin,
      Tracking.DESTINATION: Tracking.destinationData(mapToPlural(type), id)
    });

    return checkConnectivity().then(
      (value) {
        if (value) {
          return NavigationFactory.navigateToScreenFromString(type, id, context)
              .then((value) {
            return _refresh();
          });
        } else {
          _bloc.checkConnection();
        }
      },
    );
  }

  Future<void> _refresh() {
    _connectionBloc.checkConnection();
    _announceKey.currentState?.refresh();
    _shortcutKey.currentState?.refresh();
    _coursesKey.currentState?.refresh();
    _dailyMessageKey.currentState?.refresh();
    return _bloc.fetchMenu(skipCache: true);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    _bloc.dispose();
  }

  void _observeNetwork() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // print('checking observe network outside current $_connectivityResult - new $result');

      // _connectivityResult ??= result;
      //     if (_connectivityResult != result) {
      //       print('checking observe network');
      //       _connectivityResult = result;
      _refresh();
      // }
    });
  }
}
