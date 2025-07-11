import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/modern_theme.dart';
import '../screens/auth/login_screen.dart';

/// Modern animated background with multiple gradient options
class ModernBackground extends StatefulWidget {
  final Widget child;
  final int gradientIndex;
  final bool animated;

  const ModernBackground({
    super.key,
    required this.child,
    this.gradientIndex = 0,
    this.animated = true,
  });

  @override
  State<ModernBackground> createState() => _ModernBackgroundState();
}

class _ModernBackgroundState extends State<ModernBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _animationController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );
      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = ModernTheme.modernGradients;
    final selectedGradient = gradients[widget.gradientIndex % gradients.length];

    if (!widget.animated) {
      return Container(
        decoration: BoxDecoration(gradient: selectedGradient),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selectedGradient.colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Modern glass-morphism app bar
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: ModernTheme.headingMedium),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 80,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? ModernBackButton()
              : null),
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

/// Modern back button with glass effect
class ModernBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ModernBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: ModernTheme.iconButtonDecoration,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: onPressed ?? () => Navigator.pop(context),
        tooltip: 'Go back',
      ),
    );
  }
}

/// Modern logout button with confirmation
class ModernLogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;

  const ModernLogoutButton({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: ModernTheme.dangerIconButtonDecoration,
      child: IconButton(
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        onPressed: () => _showLogoutDialog(context),
        tooltip: 'Logout',
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ModernDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        icon: Icons.logout_rounded,
        iconColor: ModernTheme.errorColor,
        actions: [
          ModernDialogAction(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
            isSecondary: true,
          ),
          ModernDialogAction(
            label: 'Logout',
            onPressed: () {
              Navigator.pop(context);
              if (onLogout != null) {
                onLogout!();
              } else {
                // Default logout behavior - redirect to LoginScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            isDangerous: true,
          ),
        ],
      ),
    );
  }
}

/// Modern feature card with glass effect and animations
class ModernFeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accentColor;

  const ModernFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.accentColor,
  });

  @override
  State<ModernFeatureCard> createState() => _ModernFeatureCardState();
}

class _ModernFeatureCardState extends State<ModernFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ModernTheme.shortDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            child: Container(
              decoration: ModernTheme.glassCardDecoration.copyWith(
                color: _isPressed
                    ? Colors.white.withOpacity(0.25)
                    : Colors.white.withOpacity(0.15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ModernTheme.spacingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: (widget.accentColor ?? ModernTheme.accentColor)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (widget.accentColor ?? ModernTheme.accentColor)
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: ModernTheme.spacing),
                    Text(
                      widget.title,
                      style: ModernTheme.headingSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ModernTheme.spacingSmall),
                    Text(
                      widget.description,
                      style: ModernTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Modern welcome card with animations
class ModernWelcomeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ModernWelcomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<ModernWelcomeCard> createState() => _ModernWelcomeCardState();
}

class _ModernWelcomeCardState extends State<ModernWelcomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ModernTheme.longDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ModernTheme.spacingXLarge),
              decoration: ModernTheme.elevatedCardDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: ModernTheme.spacingLarge),
                  Text(
                    widget.title,
                    style: ModernTheme.headingLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ModernTheme.spacingSmall),
                  Text(
                    widget.subtitle,
                    style: ModernTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Modern dialog with glass effect
class ModernDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? iconColor;
  final List<ModernDialogAction> actions;

  const ModernDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.iconColor,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(ModernTheme.spacingLarge),
        decoration: ModernTheme.elevatedCardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (iconColor ?? ModernTheme.primaryColor).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? Colors.white,
                ),
              ),
              const SizedBox(height: ModernTheme.spacing),
            ],
            Text(
              title,
              style: ModernTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ModernTheme.spacing),
            Text(
              content,
              style: ModernTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ModernTheme.spacingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions.map((action) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: action,
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern dialog action button
class ModernDialogAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isDangerous;

  const ModernDialogAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDangerous
            ? ModernTheme.errorColor.withOpacity(0.2)
            : isSecondary
                ? Colors.white.withOpacity(0.1)
                : ModernTheme.primaryColor.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDangerous
                ? ModernTheme.errorColor.withOpacity(0.3)
                : isSecondary
                    ? Colors.white.withOpacity(0.2)
                    : ModernTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Modern floating action button
class ModernFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final String tooltip;

  const ModernFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Colors.white.withOpacity(0.2),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      tooltip: tooltip,
    );
  }
}
