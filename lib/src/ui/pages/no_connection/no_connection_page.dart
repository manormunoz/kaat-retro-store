import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:kaat/l10n/app_localizations.dart';

class NoConnectionPage extends StatelessWidget {
  const NoConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/svg/error2.svg", width: 160),
            const SizedBox(height: 40.0),
            Text(
              AppLocalizations.of(context)!.noConnection,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 150.0),
          ],
        ),
      ),
    );
  }
}
