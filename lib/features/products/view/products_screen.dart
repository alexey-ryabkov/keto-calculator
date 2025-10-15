import 'package:flutter/material.dart';
import 'package:keto_calculator/core/models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    required this.localProducts,
    required this.catalog,
    required this.onAddToLocal,
    required this.onAddToMenu,
    super.key,
  });
  final List<ProductData> localProducts;
  final List<ProductData> catalog;
  final void Function(ProductData) onAddToLocal;
  final void Function(ProductData) onAddToMenu;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductData> _results = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_search);
    _search();
  }

  void _search() {
    final q = _searchController.text.toLowerCase();
    final local = widget.localProducts
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
    final remote = widget.catalog
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) &&
              !local.any((l) => l.name == p.name),
        )
        .toList();
    setState(() {
      _results = [...local, ...remote];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Поиск продуктов',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _results.isEmpty
                    ? const Center(child: Text('Ничего не найдено'))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, idx) {
                          final p = _results[idx];
                          final inLocal = widget.localProducts.any(
                            (x) => x.name == p.name,
                          );
                          return ListTile(
                            leading: CircleAvatar(child: Text(p.name[0])),
                            title: Text(p.name),
                            subtitle: Text(
                              '${p.kcalPer100g} kcal /100g • ${p.keto ? 'keto' : 'not for keto'}',
                            ),
                            trailing: inLocal
                                ? ElevatedButton(
                                    onPressed: () => widget.onAddToMenu(p),
                                    child: const Text('Consume'),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () => widget.onAddToLocal(p),
                                        child: const Text('Add to products'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => widget.onAddToMenu(p),
                                        child: const Text('Add to menu'),
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
