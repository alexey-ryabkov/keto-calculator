import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:keto_calculator/app/data/spoonacular_api.dart';
import 'package:keto_calculator/core/models/product.dart';
import 'package:keto_calculator/features/products/bloc/products_state.dart';
import 'package:keto_calculator/features/products/products.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    // final jounalBloc = context.read<JournalBloc>();
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        final ProductsState(:items, :status) = state;
        switch (status) {
          case ProductsStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ProductsStatus.empty:
            return const Center(
              child: Text(
                'No any saved products yet',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          case ProductsStatus.ready:
          case ProductsStatus.saving:
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final product = items[i];
                final ProductData(:id, :name, :photo, :weight) = product;
                // final photoUrl = photo != null
                //     ? SpoonacularApi.instance.getImageUrl(photo)
                //     : null;
                return Dismissible(
                  key: ValueKey(id!),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) =>
                      context.read<ProductsBloc>().deleteProduct(id.toString()),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 40,
                      // backgroundImage: photoUrl != null
                      //     ? NetworkImage(photoUrl)
                      //     : null,
                      // child: photoUrl == null
                      backgroundImage: photo != null
                          ? NetworkImage(photo)
                          : null,
                      child: photo == null
                          ? Icon(
                              Icons.restaurant_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.surface,
                              size: 60,
                            )
                          : null,
                    ),
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${product.kcal} kcal on ${weight}g'),
                        if (product.isKetoFriendly())
                          Container(
                            margin: const EdgeInsets.only(top: 4),
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
                    ),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.local_dining_outlined),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Consume'),
                      onPressed: () {
                        // TODO
                      },
                    ),
                  ),
                );
              },
            );
          case ProductsStatus.error:
            return Center(
              child: Text('Error: ${state.error ?? 'unknown'}'),
            );
          case ProductsStatus.initial:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
