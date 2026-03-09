import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/login_footer.dart';
import 'widgets/login_header.dart';
import 'widgets/login_illustration.dart';
import 'widgets/password_input_field.dart';
import 'widgets/phone_input_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoginHeader(),
              SizedBox(height: h * 0.033),
              PhoneInputField(controller: _phoneController),
              SizedBox(height: h * 0.02),
              PasswordInputField(controller: _passwordController),
              const LoginIllustration(),
              LoginFooter(onNext: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }
}
