import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nicotine/components/logo.components.dart';
import 'package:nicotine/controllers/main.controller.dart';
import 'package:nicotine/dialogs/logon_info.dialog.dart';
import 'package:nicotine/stores/user.store.dart';
import 'package:nicotine/stores/vicio.store.dart';
import 'package:nicotine/utils/app_colors.dart';
import 'package:nicotine/views/introduction.view.dart';
import 'package:nicotine/views/login.view.dart';
import 'package:nicotine/views/main.view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreenDialog extends StatefulWidget {
  @override
  _SplashScreenDialogState createState() => _SplashScreenDialogState();
}

class _SplashScreenDialogState extends State<SplashScreenDialog> {
  bool loading = true;
  UserStore? _uStore;
  VicioStore? _vStore;
  late MainController _controller;

  Future<void> _initialFetch() async {
    try {
      await _controller.fetchUser();
    } catch (error) {
      print(error);
    }

    if (mounted) setState(() => _controller.loading = false);
  }

  @override
  void didChangeDependencies() {
    _uStore ??= Provider.of<UserStore>(context);
    _vStore ??= Provider.of<VicioStore>(context);

    _controller = MainController(_uStore!, _vStore!);
    _initialFetch().then((void value) {
      getSession().then(
        (int value) {
          if (value == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => MainView()),
            );
          } else if (value == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => LogonInfoDialog()),
            );
          } else
            setState(() {
              loading = false;
            });
        },
      );
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.12,
            ),
            LogoComponent(
              size: 400.h,
              fullLogo: true,
            ),
            Spacer(),
            loading
                ? CircularProgressIndicator()
                : Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.2.sw, vertical: 15.0.h),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size(300.w, 55.h),
                            backgroundColor: HexColor('#F4F5F5'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) {
                                  return IntroductionView();
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Vamos Começar?',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 25.0.sp,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: HexColor('#F4F5F5'),
                          minimumSize: Size(300.w, 55.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) {
                                return LoginView();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Já tenho uma conta',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 25.0.sp,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ],
        ),
      ),
    );
  }

  Future<int> getSession() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    int result = 1;
    if (sharedPreferences.getInt('token') == null) {
      return 0;
    } else if (_uStore!.user!.gender == null) {
      return 2;
    }
    return result;
  }
}
