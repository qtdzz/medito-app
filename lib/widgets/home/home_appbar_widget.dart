import 'package:Medito/network/api_response.dart';
import 'package:Medito/network/home/home_bloc.dart';
import 'package:Medito/network/home/menu_response.dart';
import 'package:Medito/network/user/user_utils.dart';
import 'package:Medito/utils/colors.dart';
import 'package:Medito/utils/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAppBar extends StatefulWidget {
  final HomeBloc _bloc;

  HomeAppBar({@required HomeBloc bloc}) : _bloc = bloc;

  @override
  State<StatefulWidget> createState() => _HomeAppBarState(_bloc);
}

class _HomeAppBarState extends State<HomeAppBar> {
  final HomeBloc _bloc;

  _HomeAppBarState(this._bloc);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc.fetchMenu();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MeditoColors.darkMoon,
      elevation: 0,
      actionsIconTheme: IconThemeData(color: MeditoColors.walterWhite),
      title: _getTitleWidget(context),
      actions: <Widget>[
        StreamBuilder<ApiResponse<MenuResponse>>(
            stream: _bloc.menuList.stream,
            initialData: ApiResponse.completed(MenuResponse(data: [])),
            builder: (context, snapshot) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                case Status.ERROR:
                  return GestureDetector(
                    onTap: () => _bloc.fetchMenu(skipCache: true),
                    child: Icon(
                      Icons.more_vert,
                      color: MeditoColors.walterWhite,
                    ),
                  );
                case Status.COMPLETED:
                  return _getMenu(context, snapshot);
                  break;
              }
              return Container();
            }),
      ],
    );
  }

  Widget _getTitleWidget(BuildContext context) => FutureBuilder<String>(
      future: _bloc.getTitleText(DateTime.now()),
      initialData: 'Medito',
      builder: (context, snapshot) {
        return GestureDetector(
          onLongPress: () => _showVersionPopUp(context),
          child:
              Text(snapshot.data, style: Theme.of(context).textTheme.headline1),
        );
      });

  PopupMenuButton<MenuData> _getMenu(
      BuildContext context, AsyncSnapshot<ApiResponse<MenuResponse>> snapshot) {
    return PopupMenuButton<MenuData>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: MeditoColors.deepNight,
      onSelected: (MenuData result) {
        NavigationFactory.navigateToScreenFromString(
            result.itemType, result.itemPath, context);
      },
      itemBuilder: (BuildContext context) {
        return snapshot.data.body.data.map((MenuData data) {
          return PopupMenuItem<MenuData>(
            value: data,
            child: Text(data.itemLabel,
                style: Theme.of(context).textTheme.headline4),
          );
        }).toList();
      },
    );
  }

  Future<void> _showVersionPopUp(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();

    var version = packageInfo.version;
    var buildNumber = packageInfo.buildNumber;

    var line1 = 'Version: $version - Build Number: $buildNumber';

    var prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString(USER_ID) ?? 'None';
    final snackBar = SnackBar(
        content: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: '$line1 $userID'));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line1, style: TextStyle(color: MeditoColors.meditoTextGrey)),
              Text(userID, style: TextStyle(color: MeditoColors.meditoTextGrey))
            ],
          ),
        ),
        backgroundColor: MeditoColors.midnight);

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
