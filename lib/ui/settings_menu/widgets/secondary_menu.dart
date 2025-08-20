import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/widgets/helpers.dart';

class SecondaryMenu extends StatelessWidget {
  const SecondaryMenu({
    super.key,
    required this.children,
    this.width = 150,
  });

  final List<Widget> children;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInkWell(
                onTap: Provider.of<VideoViewerController>(context, listen: false).closeAllSecondarySettingsMenus,
                child: Row(children: [
                  Icon(Icons.chevron_left, color: Colors.white),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              ),
              for (int i = 0; i < children.length; i++) ...[
                children[i],
              ]
            ],
          ),
        ),
      ),
    );
  }
}
