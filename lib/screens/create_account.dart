import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'loading_screen.dart';
import 'auth_service.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleCreateAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Show loading screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadingScreen(message: "Creating account...")),
      );

      // Try to register the user
      final success = await AuthService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      // Handle registration result
      if (success) {
        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Remove loading screen
        Navigator.pop(context);

        setState(() {
          _isLoading = false;
          _errorMessage = 'Email already registered';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo centered
                    Center(
                      child: Image.asset('assets/cimso_logo.png', height: 60),
                    ),
                    const SizedBox(height: 40),

                    // Title and subtitle with modern styling
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fill in your details to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Error message if registration fails
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    if (_errorMessage != null) const SizedBox(height: 20),

                    // Modern Material Design TextFields
                    _buildMaterialTextField(
                      'Username',
                      Icons.person_outline,
                      _usernameController,
                    ),
                    const SizedBox(height: 16),
                    _buildMaterialTextField(
                      'Email',
                      Icons.email_outlined,
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      'Password',
                      _passwordController,
                      isConfirmField: false,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      'Confirm Password',
                      _confirmPasswordController,
                      isConfirmField: true,
                    ),

                    const SizedBox(height: 24),

                    // Modern material button with elevation
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Or divider with modern styling
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Social login buttons in a row with modern styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModernSocialButton(FontAwesomeIcons.google, Colors.red),
                        const SizedBox(width: 16),
                        _buildModernSocialButton(FontAwesomeIcons.facebook, Colors.blue.shade800),
                        const SizedBox(width: 16),
                        _buildModernSocialButton(FontAwesomeIcons.apple, Colors.black),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sign up prompt with centered alignment
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialTextField(
      String hint,
      IconData icon,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hint,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade700, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hint is required';
        }
        if (hint.toLowerCase() == 'email' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(
      String hint,
      TextEditingController controller, {
        required bool isConfirmField,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: isConfirmField ? _obscureConfirmPassword : _obscurePassword,
      decoration: InputDecoration(
        labelText: hint,
        hintText: hint,
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade700, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirmField
                ? (_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)
                : (_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            color: Colors.grey.shade600,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              if (isConfirmField) {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              } else {
                _obscurePassword = !_obscurePassword;
              }
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hint is required';
        }
        if (!isConfirmField && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (isConfirmField && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildModernSocialButton(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}