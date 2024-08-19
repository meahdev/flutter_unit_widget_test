
import 'package:flutter/material.dart';

import '../../../model/sample_response.dart';

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.item,
  });

  final SampleResponse? item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item?.title ?? ""),
              const SizedBox(
                height: 12,
              ),
              Text(item?.body ?? ""),
            ],
          ),
        ),
      ),
    );
  }
}
