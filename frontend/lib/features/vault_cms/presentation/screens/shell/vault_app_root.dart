import 'package:flutter/material.dart';
import 'package:athirai_mobile/features/vault_cms/data/services/vault_api_service.dart';
import 'package:athirai_mobile/features/shop/presentation/screens/athirai_flow_container.dart';
import '../auth/vault_login_screen.dart';


import 'vault_web_shell.dart';

class VaultAppRoot extends StatefulWidget {
  const VaultAppRoot({
    super.key,
    this.startInClientExperience = false,
  });

  final bool startInClientExperience;

  @override
  State<VaultAppRoot> createState() => _VaultAppRootState();
}

class _VaultAppRootState extends State<VaultAppRoot> {
  final VaultApiService _apiService = VaultApiService();
  bool _isAuthenticated = true; // Auto authenticated with master credentials
  late bool _showClientMobileExperience;

  @override
  void initState() {
    super.initState();
    _showClientMobileExperience = widget.startInClientExperience;
  }

  void _handleSignOut() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  void _handleLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
      _showClientMobileExperience = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return VaultLoginScreen(
        onLoginSuccess: _handleLoginSuccess,
      );
    }

    if (_showClientMobileExperience) {
      return Stack(
        children: [
          AthiraiFlowContainer(
            initialScreenIndex: 1, // Opens Home Dashboard directly
            onSignOut: _handleSignOut,
          ),
          // Floating Button to return to Vault CMS
          Positioned(
            top: 48,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _showClientMobileExperience = false),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xEE092620),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE4C982), width: 1.2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard_customize, size: 16, color: Color(0xFFE4C982)),
                      SizedBox(width: 6),
                      Text(
                        'VAULT CMS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE4C982),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return VaultWebShell(
      apiService: _apiService,
      onSwitchToClientExperience: () => setState(() => _showClientMobileExperience = true),
      onSignOut: _handleSignOut,
    );
  }
}
