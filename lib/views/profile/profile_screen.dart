import 'package:flutter/material.dart';
import 'package:khdmti_project/comme_widget/responsive_avatar.dart';
import 'package:khdmti_project/db/auth/auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return SafeArea(
        child: Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            ListTile(
              trailing: Icon(
                Icons.share,
                color: Colors.blue,
              ),
              titleTextStyle:
                  theme.textTheme.titleMedium!.copyWith(fontSize: 26),
              title: Center(child: Text("خدماتي")),
              leading: Icon(
                Icons.settings,
                color: Color(0xff6B7280),
                size: 24,
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
            const SizedBox(
              height: 40,
            ),
            ResponsiveAvatar(),
            const SizedBox(
              height: 20,
            ),
            Text(
              Auth.user!.displayName,
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(
              height: 9,
            ),
            Text(
              Auth.user!.displayName,
              style:
                  theme.textTheme.headlineSmall!.copyWith(color: Colors.blue),
            ),
          ],
        ),
      ),
    ));
  }
}
