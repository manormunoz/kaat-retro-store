import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

PreferredSize principalAppBar(
  BuildContext context, {
  bool clear = false,
  String? title,
  String? logo,
  Icon? icon,
}) {
  return PreferredSize(
    preferredSize: Size(0, AppBar().preferredSize.height + 16),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 10.0),
      child: AppBar(
        elevation: clear ? 0 : 0.1,
        toolbarHeight: 120,
        title: logo != null || icon != null
            ? ListTile(
                leading: logo != null
                    ? CachedNetworkImage(
                        imageUrl: logo,
                        width: 30,
                        height: 30,
                        placeholder: (context, url) => SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image,
                          size: 30,
                          color: Colors.grey,
                        ),
                      )
                    : icon,
                title: Text(
                  title == null || title.isEmpty ? 'K\'aat Retro Store' : title,
                ),
              )
            : Text(
                title == null || title.isEmpty ? 'K\'aat Retro Store' : title,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).hintColor,
      ),
    ),
  );
}
