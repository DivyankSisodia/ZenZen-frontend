import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/config/app_theme.dart';
import 'package:zenzen/features/auth/login/viewmodel/oauth_viewmodel.dart';

import '../../../../config/constants.dart';
import '../../../../utils/common/custom_textfield.dart';
import '../../../../utils/common/social_media.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    ref.listen(authProvider, (previous, next) {
      if (next.failure != null) {
        if (next.failure!.message == "Email already exists") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  "This email is already registered. Try signing in instead."),
              action: SnackBarAction(
                label: "Sign In",
                onPressed: () {
                  // Switch to sign in mode or auto-sign in
                  ref
                      .read(authProvider.notifier)
                      .signInWithGoogle(true); // true for login
                },
              ),
            ),
          );
        } else {
          // Handle other errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.failure!.message)),
          );
        }
      }

      if (!previous!.isLoggedIn && next.isLoggedIn) {
        context.push(RoutesName.home);
      }
    });
    return Scaffold(
      body: authState.isLoading
          ? const CircularProgressIndicator.adaptive()
          : Container(
              padding: const EdgeInsets.all(30),
              color: AppColors.getBackgroundColor(context),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Gap(20),
                    Text(
                      'Sign In',
                      style: AppTheme.largeBodyTheme(context),
                    ),
                    const Gap(10),
                    Text(
                      'Welcome back! Sign in to continue',
                      style: AppTheme.smallBodyTheme(context),
                    ),
                    const Gap(20),
                    Card(
                      elevation: 10,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: AutofillGroup(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sign in with your email and password',
                                  style: AppTheme.smallBodyTheme(context)
                                      .copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(20),
                                Text(
                                  'Email',
                                  style: AppTheme.smallBodyTheme(context),
                                  textAlign: TextAlign.start,
                                ),
                                const Gap(5),
                                CustomTextField(
                                  autofillHints: const [AutofillHints.email],
                                  onFieldSubmitted: (value) {
                                    TextInput.finishAutofillContext();
                                  },
                                  focusNode: emailFocus,
                                  controller: emailController,
                                  hint: 'Enter your email',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    } else if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Invalid email format';
                                    }
                                    return null;
                                  },
                                ),
                                const Gap(10),
                                Text(
                                  'Password',
                                  style: AppTheme.smallBodyTheme(context),
                                  textAlign: TextAlign.start,
                                ),
                                const Gap(5),
                                CustomTextField(
                                  obscureText: true,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (value) {
                                    emailFocus.unfocus();
                                    passwordFocus.unfocus();
                                  },
                                  focusNode: passwordFocus,
                                  hint: 'Enter your password',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  controller: passwordController,
                                ),
                                const Gap(15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Don\'t have an account? ',
                                          style:
                                              AppTheme.smallBodyTheme(context)
                                                  .copyWith(
                                            color: AppColors.primary,
                                            fontSize: 15,
                                          ),
                                          children: [
                                            TextSpan(
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  context.pushNamed(
                                                      RoutesName.signup);
                                                },
                                              text: 'Sign Up',
                                              style: AppTheme.smallBodyTheme(
                                                      context)
                                                  .copyWith(
                                                color: AppColors.onSecondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          'Forgot password?',
                                          style:
                                              AppTheme.smallBodyTheme(context)
                                                  .copyWith(
                                            color: AppColors.primary,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(20),
                                Align(
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    onHover: (value) {
                                      if (value) {
                                        print('Hovering');
                                      } else {
                                        print('Not hovering');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 10,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Process login
                                        print('Email: ${emailController.text}');
                                        print(
                                            'Password: ${passwordController.text}');
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 10,
                                      ),
                                      width: double.infinity,
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        'Sign In',
                                        style: AppTheme.smallBodyTheme(context)
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          const Gap(10),
                          Text(
                            'Or sign in with',
                            style: AppTheme.smallBodyTheme(context),
                          ),
                          const Gap(10),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        SocialMediaIcon(
                          text: 'Google',
                          icon: FontAwesomeIcons.google,
                          onTap: () {
                            // Process google login
                            print('Google login');
                            ref
                                .read(authProvider.notifier)
                                .signInWithGoogle(true); // false for signup
                            context.goNamed(RoutesName.home);
                          },
                        ),
                        const Gap(10),
                        SocialMediaIcon(
                          text: 'Apple',
                          icon: FontAwesomeIcons.apple,
                          onTap: () {
                            // Process apple login
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
