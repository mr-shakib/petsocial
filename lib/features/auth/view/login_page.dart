import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'widgets/login_footer.dart';
import 'widgets/login_header.dart';
import 'widgets/login_illustration.dart';
import 'widgets/password_input_field.dart';
import 'widgets/phone_input_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _fullPhone = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final phone = _fullPhone.isNotEmpty ? _fullPhone : _phoneController.text.trim();
    final password = _passwordController.text.trim();
    if (phone.isEmpty || password.isEmpty) return;

    final success = await ref.read(authProvider.notifier).login(phone, password);
    if (success && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final auth = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                MediaQuery.sizeOf(context).width * 0.05,
              ),
            ),
            title: const Text('Login Failed'),
            content: Text(next.error!),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoginHeader(),
              SizedBox(height: h * 0.033),
              PhoneInputField(
                controller: _phoneController,
                onCompleteNumber: (n) => _fullPhone = n,
              ),
              SizedBox(height: h * 0.02),
              PasswordInputField(controller: _passwordController),
              const LoginIllustration(),
              LoginFooter(
                onNext: auth.isLoading ? null : () => _onNext(),
                isLoading: auth.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
