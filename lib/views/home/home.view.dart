import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nicotine/components/home/feature_card.component.dart';
import 'package:nicotine/components/shimmer/home_shimmer.component.dart';
import 'package:nicotine/controllers/home.controller.dart';
import 'package:nicotine/providers/firebase.provider.dart';
import 'package:nicotine/stores/user.store.dart';
import 'package:nicotine/utils/app_colors.dart';
import 'package:nicotine/views/home/profile.view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  HomeView();

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late UserStore _uStore;
  late String avatarUrl;
  List<Map<String, String>> dataMap = [
    {
      'value': '27',
      'desc': 'Dias',
    },
    {
      'value': 'R\$: 134,00',
      'desc': 'Economizados',
    },
    {
      'value': '2',
      'desc': 'Metas ativas',
    },
  ];
  HomeController? _homeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _uStore = Provider.of<UserStore>(context);
    _homeController ??= HomeController();
    _initialFetch();
  }

  @override
  Widget build(BuildContext context) {
    return _homeController!.isLoading
        ? HomeShimmerComponent()
        : Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 1.0, bottom: 5.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ProfileView(
                            () => setState(() {}),
                          );
                        },
                      ),
                    );
                  },
                  child: _uStore.user!.avatar != null
                      ? CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(avatarUrl))
                      : CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_uStore.user!.name),
                  Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.trophy,
                        size: 14.0,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text('250'),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                CircleAvatar(
                  child: Image.asset('assets/vicioLogo/tabagismoLogo.png'),
                  radius: 16,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Icon(
                  Icons.notifications_outlined,
                  size: 28,
                ),
                SizedBox(
                  width: 15.0,
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 150.h,
                    width: double.maxFinite,
                    color: AppColors.backgroundColor,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0.h),
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(width: 35.0.w),
                      itemCount: dataMap.length,
                      itemBuilder: (BuildContext context, int index) => SizedBox(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          color: AppColors.secondaryColor,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.0.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  dataMap[index]['value']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0.sp,
                                  ),
                                ),
                                Text(
                                  dataMap[index]['desc']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 22.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35.0),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          Text(
                            _homeController!.getInitialMessage(_uStore.user!.name),
                            style: TextStyle(
                              color: AppColors.backgroundColor,
                              fontSize: 22.0.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          ...buildFeatures(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  List<Widget> buildFeatures() {
    List<Map<String, dynamic>> data = _homeController!.getFeatures();
    return List<Widget>.generate(
      data.length,
      (int index) {
        return Column(
          children: <Widget>[
            FeatureCardComponent(
              data[index]['icon'],
              data[index]['title'],
              data[index]['desc'],
              route: data[index]['route'],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
          ],
        );
      },
    );
  }

  Future<void> _initialFetch() async {
    if (_uStore.user!.avatar != null) {
      avatarUrl = await FirebaseProvider().getUserAvatar(_uStore.user!.nickname);

      print(avatarUrl);
    }
    if (mounted) setState(() => _homeController!.isLoading = false);
  }
}
