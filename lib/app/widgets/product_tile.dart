import 'package:flutter/material.dart';
import 'package:keto_calculator/app/utils/utils.dart';
import 'package:keto_calculator/core/models/nutrition.dart';
import 'package:keto_calculator/core/models/product.dart';
import 'package:keto_calculator/core/utils/utils.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    this.item,
    this.details,
    this.trailing,
    super.key,
  });
  final ProductItem? item;
  final StoredConsumable? details;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hasDetails = details != null;
    if (item == null && !hasDetails) {
      return const SizedBox.shrink();
    }
    final (formatedNutrients, formatedKcal) = hasDetails
        ? formatNutrients(
            details!,
            onWeight: details!.weight,
          )
        : ('', '');
    final photoPlaceholder = Icon(
      Icons.restaurant_outlined,
      color: Theme.of(
        context,
      ).colorScheme.surface,
      size: 60,
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      // visualDensity: const VisualDensity(horizontal: 0),
      leading: hasDetails
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 64,
                height: 64,
                color: Theme.of(context).colorScheme.outlineVariant,
                child: details!.photo != null
                    ? Image.network(
                        details!.photo!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : photoPlaceholder,
                        errorBuilder: (_, _, _) => photoPlaceholder,
                      )
                    : photoPlaceholder,
              ),
            )
          : null,
      title: Text(
        (item?.name.capitalize() ?? details?.name.capitalize())!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: hasDetails ? FontWeight.w500 : null,
        ),
      ),
      subtitle: hasDetails
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (formatedNutrients.isNotEmpty) Text(formatedNutrients),
                if (formatedKcal.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(formatedKcal),
                ],
                if (details!.isKetoFriendly())
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'keto',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : null,
      trailing: trailing,
      dense: false,
    );
  }
}
