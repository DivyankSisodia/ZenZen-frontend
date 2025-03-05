import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/config/app_theme.dart';
import '../../../../data/failure.dart';
import '../../../../utils/common/custom_textfield.dart';
import '../viewmodel/auth_viewmodel.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode mobileFocus = FocusNode();

  bool isAgree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Register your Info',
                        style: AppTheme.largeBodyTheme(context),
                      ),
                      const Gap(10),
                      Text(
                        'Please fill in the form below to register your information',
                        style: AppTheme.smallBodyTheme(context),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(20),
                      Card(
                        elevation: 10,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style:
                                      AppTheme.smallBodyTheme(context).copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(20),
                                buildPersonalInfoSection(constraints),
                                const Gap(20),
                                buildTextField(
                                  inputType: TextInputType.phone,
                                  focus: mobileFocus,
                                  'Phone Number',
                                  mobileController,
                                  hint: 'Enter your phone number',
                                  autofillHints: [
                                    AutofillHints.telephoneNumber
                                  ],
                                ),
                                const Gap(20),
                                buildTextField(
                                  focus: emailFocus,
                                  'Email',
                                  emailController,
                                  hint: 'Enter your email',
                                  autofillHints: [AutofillHints.email],
                                ),
                                const Gap(20),
                                buildSignInLink(context),
                                const Gap(20),
                                buildSignUpButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPersonalInfoSection(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: constraints.maxWidth < 400 ? 40 : 50,
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.person,
            size: constraints.maxWidth < 400 ? 30 : 40,
            color: AppColors.getBackgroundColor(context),
          ),
        ),
        const Gap(20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username',
                style: AppTheme.smallBodyTheme(context),
              ),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      focusNode: firstNameFocus,
                      obscureText: false,
                      hint: 'First name',
                      controller: firstName,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: CustomTextField(
                      focusNode: lastNameFocus,
                      obscureText: false,
                      hint: 'Last name',
                      controller: lastName,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    List<String>? autofillHints,
    FocusNode? focus,
    TextInputType? inputType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.smallBodyTheme(context),
        ),
        const Gap(5),
        CustomTextField(
          keyboardType: inputType,
          controller: controller,
          hint: hint!,
          autofillHints: autofillHints,
          focusNode: focus!,
        ),
      ],
    );
  }

  Widget buildSignInLink(BuildContext context) {
    return Row(
      children: [
        CupertinoCheckbox(
          value: isAgree,
          onChanged: (value) {
            setState(() {
              isAgree = value!;
            });
          },
        ),
        const Gap(30),
        Flexible(
          child: Text(
            'I agree to the Terms of Service and Privacy Policy',
            style: AppTheme.smallBodyTheme(context).copyWith(
              fontSize: 13,
            ),
          ),
        )
      ],
    );
  }

  Widget buildSignUpButton() {
    final authState = ref.watch(authStateProvider);
    final authViewModel = ref.watch(authStateProvider.notifier);
    return authState.isLoading
        ? const CircularProgressIndicator.adaptive()
        : SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Perform sign up logic
                      authViewModel.register(
                        emailController.text.trim(),
                        '${firstName.text.trim()} ${lastName.text.trim()}',
                        mobileController.text.trim(),
                        'avatar',
                        context,
                      );
                    }
                  },
                  child: Text(
                    'Register Info',
                    style: AppTheme.smallBodyTheme(context)
                        .copyWith(color: Colors.white),
                  ),
                ),
                const Gap(15),
                authState.hasError
                    ? Text(
                        authState.error is ApiFailure
                            ? (authState.error as ApiFailure).error
                            : authState.error.toString(),
                        style: AppTheme.smallBodyTheme(context)
                            .copyWith(color: Colors.red),
                      )
                    : const SizedBox(),
              ],
            ),
          );
  }
}
