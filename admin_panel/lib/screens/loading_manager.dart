

import 'package:flutter/material.dart';
class LoadingManager extends StatelessWidget {
  const LoadingManager({super.key, this.isLoading, required this.child});
  final isLoading ;
  final Widget child ;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        isLoading
            ? Container(
                color: Colors.black.withOpacity(0.7),
              )
            : Container(),
        isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Container(),
      ],
    );
  }
}