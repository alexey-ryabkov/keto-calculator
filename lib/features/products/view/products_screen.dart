import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/features/products/bloc/products_state.dart';
import 'package:keto_calculator/features/products/products.dart';
import 'package:keto_calculator/features/products/view/search_screen.dart';
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

  void _openSearch(BuildContext context) {
    final productsBloc = context.read<ProductsBloc>();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider.value(
          value: productsBloc,
          child: SearchScreen(
            onSave: productsBloc.saveProduct,
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Saved Products'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _openSearch(context),
                    child: const AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search product in reference',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
