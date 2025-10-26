import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/widgets/product_tile.dart';
import 'package:keto_calculator/core/models/journal_entry.dart';
import 'package:keto_calculator/core/models/product.dart';
import 'package:keto_calculator/core/utils/utils.dart';
import 'package:keto_calculator/features/products/bloc/products_state.dart';
import 'package:keto_calculator/features/products/products.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_bloc.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    final jounalBloc = context.read<JournalBloc>();
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
                      context.read<ProductsBloc>().deleteProduct(id),
                  child: ProductTile(
                    details: product,
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.local_dining_outlined),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Eat'),
                      onPressed: () {
                        jounalBloc.addEntry(
                          JournalEntry.fromConsumable(
                            product,
                            title:
                                '${formatNumber(product.weight)}g of '
                                '${product.name}',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Journal entry added')),
                        );
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
