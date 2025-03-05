import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_provider.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      Card(
                        elevation: 10,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'OTP', hintText: 'Enter OTP'),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // Verify OTP logic
                                },
                                child: const Text('Verify'),
                              ),
                            ],
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
}
