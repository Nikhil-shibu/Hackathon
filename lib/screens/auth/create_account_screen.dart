import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'condition_selection_screen.dart';
import '../../themes/minimalistic_theme.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  String? _selectedGender;
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalisticTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: MinimalisticTheme.headingMedium,
        ),
        backgroundColor: MinimalisticTheme.backgroundColor,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MinimalisticTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Welcome Message
              const Icon(
                Icons.person_add,
                size: 60,
                color: MinimalisticTheme.primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Join Thrive Mind',
                style: MinimalisticTheme.headingLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your personalized account to get started',
                style: MinimalisticTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Form Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: MinimalisticTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MinimalisticTheme.accentColor,
                    width: 1,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Field
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Age Field
                      _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        hint: 'Enter your age',
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 1 || age > 120) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Mobile Number Field
                      _buildTextField(
                        controller: _mobileController,
                        label: 'Mobile Number',
                        hint: 'Enter your mobile number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (value.length < 10) {
                            return 'Mobile number must be at least 10 digits';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address (Username)',
                        hint: 'Enter your email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Gender Dropdown
                      _buildDropdownField(
                        label: 'Gender',
                        hint: 'Select your gender',
                        icon: Icons.person_outline,
                        value: _selectedGender,
                        items: _genderOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your gender';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Confirm Password Field
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Create Account Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MinimalisticTheme.primaryColor,
                          foregroundColor: MinimalisticTheme.backgroundColor,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Create Account',
                                style: MinimalisticTheme.bodyLarge.copyWith(
                                  color: MinimalisticTheme.backgroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Terms and Conditions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'By creating an account, you agree to our Terms of Service and Privacy Policy. Your information is secure and used only to provide you with personalized support.',
                          style: MinimalisticTheme.bodyMedium,
                          textAlign: TextAlign.center,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16),
        hintText: hint,
        prefixIcon: Icon(icon, size: 24),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16),
        hintText: hint,
        prefixIcon: Icon(icon, size: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
      ),
      style: const TextStyle(fontSize: 18, color: Colors.black),
      dropdownColor: Colors.white,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(fontSize: 18),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    print('DEBUG: Form validation passed');
    setState(() {
      _isLoading = true;
    });
    print('DEBUG: Loading state set to true');

    try {
      print('DEBUG: Starting simplified account creation...');
      
      // Create Firebase user account with timeout
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('DEBUG: Firebase auth timeout!');
          throw Exception('Authentication timeout');
        },
      );
      
      print('DEBUG: Account creation successful, user: ${userCredential.user?.email}');

      // Skip Firestore operations for now to test basic functionality
      if (mounted && userCredential.user != null) {
        print('DEBUG: Navigating to condition selection...');
        
        // Reset loading state before navigation
        setState(() {
          _isLoading = false;
        });
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ConditionSelectionScreen(),
          ),
        );
        return; // Exit early on success
      }
      
    } on FirebaseAuthException catch (e) {
      print('DEBUG: FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'Account creation failed: ${e.message ?? 'Unknown error'}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: General exception: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      print('DEBUG: Finally block - resetting loading state');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

}
