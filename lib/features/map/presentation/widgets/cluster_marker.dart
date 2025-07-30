// lib/features/map/presentation/widgets/cluster_marker.dart

import 'package:flutter/material.dart';

class ClusterMarker extends StatelessWidget {
  final int count;
  final bool showText;

  const ClusterMarker({super.key, required this.count, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.teal,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child:
          showText
              ? Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
              : null, // showText가 false이면 아무것도 표시하지 않음
    );
  }
}
