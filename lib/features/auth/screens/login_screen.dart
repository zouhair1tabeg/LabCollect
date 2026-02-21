import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../../../core/theme/liquid_glass_theme.dart';
import '../../../shared/widgets/glass_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static final RegExp _emailRegex = RegExp(
    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: LiquidGlass.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return GlassScaffold(
      showAppBar: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 28,
                child: Icon(
                  Icons.science_rounded,
                  size: 56,
                  color: LiquidGlass.accentBlue,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text('LabCollect', style: LiquidGlass.heading(fontSize: 36)),
              const SizedBox(height: 8),
              Text('COLLECTE DE DONNÉES TERRAIN', style: LiquidGlass.label()),

              const SizedBox(height: 48),

              // Login Form
              GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GlassInput(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        labelText: 'Email',
                        hintText: 'votre@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!_emailRegex.hasMatch(value.trim())) {
                            return 'Format d\'email invalide';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      GlassInput(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        labelText: 'Mot de passe',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: LiquidGlass.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 4) {
                            return 'Le mot de passe doit contenir au moins 4 caractères';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Error message
                      if (authState.status == AuthStatus.error &&
                          authState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: LiquidGlass.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: LiquidGlass.error.withValues(
                                  alpha: 0.30,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: LiquidGlass.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.error!,
                                    style: LiquidGlass.body(
                                      fontSize: 14,
                                    ).copyWith(color: LiquidGlass.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          label: 'Se connecter',
                          isLoading: authState.isLoading,
                          onPressed: authState.isLoading ? null : _handleLogin,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
