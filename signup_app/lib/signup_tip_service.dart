
import 'dart:async';

class SignupTipResult {
  final String tip;
  final bool isMock;

  const SignupTipResult({
    required this.tip,
    required this.isMock,
  });
}

abstract class SignupTipService {
  Future<SignupTipResult> getSignupTip();
}

class MockSignupTipService implements SignupTipService {
  @override
  Future<SignupTipResult> getSignupTip() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return const SignupTipResult(
      tip: 'Use a long, unique password. A passphrase made of several '
          'unrelated words can be easier to remember and harder to guess.',
      isMock: true,
    );
  }
}
