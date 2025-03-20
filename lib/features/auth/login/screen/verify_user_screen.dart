import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/router/constants.dart';

import '../provider/auth_provider.dart';
import '../viewmodel/auth_viewmodel.dart';

class VerifyUserScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyUserScreen({super.key, required this.email});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerifyUserScreenState();
}

class _VerifyUserScreenState extends ConsumerState<VerifyUserScreen> {
  bool isSendingOtp = false;
  String? errorMessage;

  TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger sendOtp after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendOtp();
    });
  }

  Future<void> sendOtp() async {
    if (!mounted) return;
    setState(() {
      isSendingOtp = true;
      errorMessage = null;
    });

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.sendOtp(widget.email);

    if (!mounted) return;
    result.fold(
      (otpModel) {
        // Success: OTP sent
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to ${widget.email}'),
          ),
        );
      },
      (failure) {
        // Error: Show failure message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: ${failure.error}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          errorMessage = failure.error;
        });
      },
    );

    setState(() => isSendingOtp = false);
  }

  @override
  void dispose() {
    super.dispose();
    otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: authState.isLoading
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Verify your account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Please enter the OTP sent to your email',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isSendingOtp) // Show loading indicator
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ),
                            if (errorMessage != null) // Show error message
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Pinput(
                              animationCurve: Curves.linear,
                              length: 6,
                              controller: otpController,
                              onCompleted: (value) {
                                setState(() {
                                  isSendingOtp = true; // Show loading indicator
                                });
                                ref
                                    .read(authRepositoryProvider)
                                    .verifyUser(
                                      widget.email,
                                      value,
                                    )
                                    .then((_) {
                                  setState(() {
                                    isSendingOtp = false;
                                  });
                                });

                                context.goNamed(
                                  RoutesName.home,
                                );
                              },
                            ),
                            authState.hasError
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      authState.error.toString(),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(authRepositoryProvider).sendOtp(
                                      widget.email,
                                    );
                              },
                              child: const Text('Resend OTP'),
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
}
