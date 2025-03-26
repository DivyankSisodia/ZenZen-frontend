import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/router/constants.dart';

import '../../../../data/failure.dart';
import '../../../../utils/common/custom_textfield.dart';
import '../../../../utils/common/social_media.dart';
import '../../../../utils/theme.dart';
import '../../login/viewmodel/auth_viewmodel.dart';
import '../../login/viewmodel/oauth_viewmodel.dart';

class DesktopIntro extends ConsumerStatefulWidget {
  const DesktopIntro({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DesktopIntroState();
}

class _DesktopIntroState extends ConsumerState<DesktopIntro> {
  final titles = [
    'Online Text Editor',
    'Seamless Collaboration',
    'Real-time Preview & Chat',
  ];

  final description = [
    'Create, edit, and collaborate on text documents with ease.',
    'Work together with your team in real-time on the same document.',
    'Preview your document in real-time and chat with your team.',
  ];

  final PageController _controller = PageController();
  int currentPage = 0;

  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page != null) {
        setState(() {
          currentPage = _controller.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OAuthState = ref.watch(authProvider);
    final authState = ref.watch(authStateProvider);
    final authViewModel = ref.watch(authStateProvider.notifier);
    ref.listen(authProvider, (previous, next) {
      if (next.failure != null) {
        if (next.failure!.error == "Email already exists") {
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
                      .signInWithGoogle(true, context); // true for login
                },
              ),
            ),
          );
        } else {
          print(next.failure!.error);
          // Handle other errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.failure!.error)),
          );
        }
      }
    });
    return Container(
      height: MediaQuery.of(context).size.height + 200,
      color: AppColors.getBackgroundColor(context),
      child: OAuthState.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Row(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: Column(
                          children: [
                            Image.asset(
                              height: 400,
                              'assets/images/doodle_pen.png',
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              titles[index],
                              style: AppTheme.introPageTitleStyle(context),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description[index],
                              style: AppTheme.descriptionTextStyle(context),
                            ),
                            const Gap(20),
                            SmoothPageIndicator(
                              controller: _controller,
                              count: 3,
                              effect: ExpandingDotsEffect(
                                dotWidth: 10,
                                dotHeight: 10,
                                activeDotColor: Theme.of(context).primaryColor,
                                dotColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5),
                              ),
                            ),
                            const Gap(30),
                            ElevatedButton(
                              onPressed: () {
                                // Otherwise, go to next page
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                );
                              },
                              child: Text(
                                currentPage == 2 ? 'Start Over' : 'Next',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const Gap(10),
                            TextButton(
                              onPressed: () {
                                _controller.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                );
                              },
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Gap(15),
                Container(
                  height: MediaQuery.of(context).size.height - 100,
                  width: 2,
                  color: AppColors.primary,
                ),
                const Gap(5),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height + 100,
                      padding: const EdgeInsets.all(50),
                      margin: const EdgeInsets.all(20),
                      color: AppColors.getBackgroundColor(context),
                      alignment: Alignment.center,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      CustomAuthTextField(
                                        autofillHints: const [
                                          AutofillHints.email
                                        ],
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
                                      CustomAuthTextField(
                                        obscureText: true,
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
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
                                                text:
                                                    'Don\'t have an account? ',
                                                style: AppTheme.smallBodyTheme(
                                                        context)
                                                    .copyWith(
                                                  color: AppColors.primary,
                                                  fontSize: 15,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            // Navigate to sign up screen
                                                            context.goNamed(
                                                                RoutesName
                                                                    .signup);
                                                          },
                                                    text: 'Sign Up',
                                                    style:
                                                        AppTheme.smallBodyTheme(
                                                                context)
                                                            .copyWith(
                                                      color: AppColors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                style: AppTheme.smallBodyTheme(
                                                        context)
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
                                      authState.isLoading
                                          ? const Center(
                                              child: CircularProgressIndicator
                                                  .adaptive())
                                          : Align(
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 30,
                                                    vertical: 10,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    authViewModel.login(
                                                      emailController.text,
                                                      passwordController.text,
                                                      context,
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 30,
                                                    vertical: 10,
                                                  ),
                                                  width: double.infinity,
                                                  child: Text(
                                                    textAlign: TextAlign.center,
                                                    'Sign In',
                                                    style:
                                                        AppTheme.smallBodyTheme(
                                                                context)
                                                            .copyWith(
                                                                color: Colors
                                                                    .white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      authState.hasError
                                          ? Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(10),
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.red[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                (authState.error is ApiFailure)
                                                    ? (authState.error
                                                            as ApiFailure)
                                                        .error // Correct way to access the error message
                                                    : authState.error
                                                        .toString(),
                                                style: AppTheme.smallBodyTheme(
                                                        context)
                                                    .copyWith(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            )
                                          : Container(),
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
                                  print('Google login');
                                  ref
                                      .read(authProvider.notifier)
                                      .signInWithGoogle(
                                          true, context); // false for signup
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
                ),
              ],
            ),
    );
  }
}
