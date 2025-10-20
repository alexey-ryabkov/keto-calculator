import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/features/products/bloc/products_state.dart';
import 'package:keto_calculator/features/products/products.dart';
import 'package:keto_calculator/features/products/widgets/products_list.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productsBloc = context.read<ProductsBloc>();
      if (mounted && productsBloc.state.status == ProductsStatus.initial) {
        unawaited(productsBloc.init());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Align(
                    child: Text(
                      'Saved products',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Expanded(child: ProductsList()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
