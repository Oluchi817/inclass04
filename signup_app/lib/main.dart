
import 'package:flutter/material.dart';
import 'signup_tip_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
        ),
        useMaterial3: true,
      ),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Mock service until the instructor provides the HTTPS proxy.
  final SignupTipService _tipService =
      MockSignupTipService();

  bool _isLoadingTip = false;
  String? _tip;
  String? _tipError;
  bool _tipIsMock = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _getSignupTip() async {
    if (_isLoadingTip) return;

    setState(() {
      _isLoadingTip = true;
      _tip = null;
      _tipError = null;
    });

    try {
      final result = await _tipService
          .getTip()
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      setState(() {
        _tip = _trimTip(result.tip);
        _tipIsMock = result.isMock;
        _isLoadingTip = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _tipError =
            'We couldn’t load a signup tip right now. '
            'Please try again.';
        _isLoadingTip = false;
      });
    }
  }

  String _trimTip(String value) {
    final trimmed = value.trim();

    if (trimmed.length <= 240) {
      return trimmed;
    }

    return trimmed.substring(0, 240).trimRight();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Welcome! Account created successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Join the Quest',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email Address
                  TextFormField(
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      final atIndex = email.indexOf('@');

                      if (atIndex <= 0 ||
                          atIndex == email.length - 1 ||
                          !email
                              .substring(atIndex + 1)
                              .contains('.')) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.length < 6) {
                        return 'Password must be at least '
                            '6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Signup button: local validation only
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Sign Up'),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 12),

                  // AI Signup Coach
                  const Text(
                    'AI Signup Coach',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Get a general tip for creating a stronger '
                    'signup password. Your form entries are '
                    'never sent to the coach.',
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _isLoadingTip
                        ? null
                        : _getSignupTip,
                    icon: _isLoadingTip
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.lightbulb_outline,
                          ),
                    label: Text(
                      _isLoadingTip
                          ? 'Getting a tip...'
                          : 'Get a signup tip',
                    ),
                  ),

                  // Loading state
                  if (_isLoadingTip) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Loading tip...',
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Advice result
                  if (_tip != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tipIsMock
                                ? 'Mock signup advice '
                                    '(no live AI model called)'
                                : 'AI-generated advice',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Plain text, maximum 240 characters.
                          Text(_tip!),

                          const SizedBox(height: 8),

                          const Text(
                            'This is general advice only. It does '
                            'not approve or reject signup and does '
                            'not replace form validation.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Error state and retry
                  if (_tipError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .error,
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(_tipError!),

                          const SizedBox(height: 8),

                          TextButton.icon(
                            onPressed: _isLoadingTip
                                ? null
                                : _getSignupTip,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
