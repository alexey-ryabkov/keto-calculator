import 'package:flutter/material.dart';
import 'package:keto_calculator/core/models/meal.dart';
import 'package:keto_calculator/core/models/product.dart';

class MenuScreen extends StatefulWidget {
  final List<Meal> localMeals;
  final List<Product> localProducts;
  final void Function(Product product) onConsumeFromLocal;
  final void Function(int index) onDeleteMealAt;
  final VoidCallback onAddMealPressed;

  const MenuScreen({
    super.key,
    required this.localMeals,
    required this.localProducts,
    required this.onConsumeFromLocal,
    required this.onDeleteMealAt,
    required this.onAddMealPressed,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSuggestions);
    _updateSuggestions();
  }

  void _updateSuggestions() {
    final q = _searchController.text.toLowerCase();
    final all = widget.localProducts;
    setState(() {
      if (q.isEmpty) {
        _suggestions = all.take(6).toList();
      } else {
        _suggestions = all
            .where((p) => p.name.toLowerCase().contains(q))
            .take(8)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meals = widget.localMeals;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Autocomplete<Product>(
                optionsBuilder: (textEditingValue) {
                  final q = textEditingValue.text.toLowerCase();
                  if (q.isEmpty) return const Iterable<Product>.empty();
                  final localMatches = widget.localProducts.where(
                    (p) => p.name.toLowerCase().contains(q),
                  );
                  // no remote API here, so only local suggestions
                  return localMatches;
                },
                displayStringForOption: (p) => p.name,
                fieldViewBuilder:
                    (context, controller, focusNode, onSubmitted) {
                      controller.text = _searchController.text;
                      controller.selection = _searchController.selection;
                      controller.addListener(() {
                        _searchController.text = controller.text;
                        _searchController.selection = controller.selection;
                      });
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Поиск по меню',
                        ),
                      );
                    },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 24,
                        child: ListView(
                          shrinkWrap: true,
                          children: options.map((p) {
                            return ListTile(
                              leading: CircleAvatar(child: Text(p.name[0])),
                              title: Text(p.name),
                              subtitle: Text('${p.kcalPer100g} kcal /100g'),
                              onTap: () => onSelected(p),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (p) {
                  // consume selected product (demo behaviour)
                  widget.onConsumeFromLocal(p);
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: meals.isEmpty
                    ? Center(child: Text('Список пуст — нажмите Add meal'))
                    : ListView.builder(
                        itemCount: meals.length,
                        itemBuilder: (context, idx) {
                          final m = meals[idx];
                          return Dismissible(
                            key: ValueKey('${m.product.name}-$idx'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => widget.onDeleteMealAt(idx),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(m.product.name[0]),
                              ),
                              title: Text(m.product.name),
                              subtitle: Text(
                                '${m.product.kcalPer100g} kcal /100g • ${m.product.keto ? 'keto' : 'not for keto'}',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () =>
                                    widget.onConsumeFromLocal(m.product),
                                child: const Text('Consume'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: widget.onAddMealPressed,
          label: const Text('Add meal'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}
