import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

/// Bottom sheet with quick contact options (call, Zalo, email).
/// Replace the placeholder phone/email/Zalo values with your real ones.
void showContactSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 18),
            Text(l10n.t('contactUs'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF073B4C))),
            const SizedBox(height: 16),
            _ContactTile(
              icon: Icons.call,
              label: l10n.t('callHotline'),
              subtitle: '+84 90 123 4567',
              onTap: () => launchUrl(Uri.parse('tel:+84901234567')),
            ),
            _ContactTile(
              icon: Icons.chat_bubble_outline,
              label: l10n.t('chatZalo'),
              subtitle: 'zalo.me/lumasea',
              onTap: () => launchUrl(Uri.parse('https://zalo.me/'), mode: LaunchMode.externalApplication),
            ),
            _ContactTile(
              icon: Icons.email_outlined,
              label: l10n.t('emailUs'),
              subtitle: 'hello@lumasea.vn',
              onTap: () => launchUrl(Uri.parse('mailto:hello@lumasea.vn')),
            ),
          ]),
        ),
      );
    },
  );
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFFDFF6FA), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: const Color(0xFF0E7490)),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
    );
  }
}
