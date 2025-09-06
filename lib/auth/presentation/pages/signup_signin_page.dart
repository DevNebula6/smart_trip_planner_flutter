import 'package:flutter/material.dart';
import 'package:smart_trip_planner_flutter/core/constants/app_styles.dart';
import 'package:smart_trip_planner_flutter/shared/navigation/app_router.dart';

enum AuthMode { signUp, signIn }

class SignUpSignInPage extends StatefulWidget {
  const SignUpSignInPage({super.key});

  @override
  State<SignUpSignInPage> createState() => _SignUpSignInPageState();
}

class _SignUpSignInPageState extends State<SignUpSignInPage>
    with TickerProviderStateMixin {
  AuthMode _authMode = AuthMode.signUp;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;
  
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.signUp ? AuthMode.signIn : AuthMode.signUp;
      _rememberMe = false; // Reset remember me when switching modes
    });
    
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              // App Logo and Branding
              _buildAppBranding(),
              
              const SizedBox(height: AppDimensions.marginXL),
              
              // Animated Content
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildContent(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBranding() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          child: Center(
            child: Image.asset(
              'assets/material-symbols-light_travel-rounded.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.flight_takeoff,
                  size: 40,
                  color: AppColors.orange,
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: AppDimensions.marginM),
        
        // App Name
        const Text(
          'Itinera AI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Title and Subtitle - Centered
          _buildTitleSection(),
          
          const SizedBox(height: AppDimensions.marginXL),
          
          // Google Sign In/Up Button
          _buildGoogleButton(),
          
          const SizedBox(height: AppDimensions.marginL),
          
          // Divider
          _buildDivider(),
          
          const SizedBox(height: AppDimensions.marginL),
          
          // Email Field
          _buildEmailField(),
          
          const SizedBox(height: AppDimensions.marginL),
          
          // Password Field
          _buildPasswordField(),
          
          // Animated Confirm Password Field (only for sign up)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _authMode == AuthMode.signUp ? null : 0,
            child: _authMode == AuthMode.signUp 
                ? Column(
                    children: [
                      const SizedBox(height: AppDimensions.marginL),
                      _buildConfirmPasswordField(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          
          // Remember Me and Forgot Password (only for sign in)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _authMode == AuthMode.signIn ? null : 0,
            child: _authMode == AuthMode.signIn 
                ? Column(
                    children: [
                      const SizedBox(height: AppDimensions.marginL),
                      _buildRememberAndForgot(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          
          const SizedBox(height: AppDimensions.marginXL),
          
          // Main Action Button
          _buildMainActionButton(),
          
          const SizedBox(height: AppDimensions.marginL),
          
          // Toggle Auth Mode
          _buildAuthModeToggle(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          _authMode == AuthMode.signUp 
              ? 'Create your Account'
              : 'Hi, Welcome Back',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppDimensions.marginS),
        Text(
          _authMode == AuthMode.signUp 
              ? 'Lets get started'
              : 'Login to your account',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightL,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Handle Google sign in/up
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.grey, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child:Image.asset("assets/icons/Google Icon.png")
              
            ),
            const SizedBox(width: AppDimensions.marginM),
            Text(
              _authMode == AuthMode.signUp 
                  ? 'Sign up with Google'
                  : 'Sign in with Google',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.grey,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
          child: Text(
            _authMode == AuthMode.signUp 
                ? 'or Sign up with Email'
                : 'or Sign in with Email',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.grey,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppDimensions.marginS),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'john@example.com',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.secondaryText,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppDimensions.marginS),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: '••••••••••',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.secondaryText,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.secondaryText,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppDimensions.marginS),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            hintText: '••••••••••',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.secondaryText,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.secondaryText,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
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
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: AppColors.primaryGreen,
            ),
            const Text(
              'Remember me',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: Handle forgot password
          },
          child: const Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButton() {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightL,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_authMode == AuthMode.signUp) {
              // TODO: Handle sign up
              print('Sign up pressed');
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);

            } else {
              // TODO: Handle login
              print('Login pressed');
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          elevation: 2,
        ),
        child: Text(
          _authMode == AuthMode.signUp ? 'Sign UP' : 'Login',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _authMode == AuthMode.signUp 
              ? 'Already have an account? '
              : 'New user? ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
        ),
        TextButton(
          onPressed: _toggleAuthMode,
          child: Text(
            _authMode == AuthMode.signUp ? 'Sign In' : 'Sign Up',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
