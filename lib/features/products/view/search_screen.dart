import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keto_calculator/app/data/spoonacular_api.dart';
import 'package:keto_calculator/core/models/product.dart';
import 'package:keto_calculator/core/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

const _minInputLettersCnt = 3;
const _searchInputDebounceTime = 300;
const _searchRequestMinTime = 500;
const _showingLoaderMinTime = 300;

class SearchState {
  const SearchState({required this.loading, this.items});
  final List<ProductItem>? items;
  final bool loading;

  @override
  String toString() =>
      'SearchState(loading: $loading, count: ${items?.length ?? 0}';
  // 'items: $items)';
}

class SearchScreen extends StatefulWidget {
  SearchScreen({required this.onSave, super.key});

  final void Function(ProductData data) onSave;

  // TODO by props?
  final SpoonacularApi api = SpoonacularApi.instance;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchQuery$ = BehaviorSubject<String>();
  StreamSubscription<SearchState>? _searching;

  bool _productsLoading = false;
  List<ProductItem>? _foundProducts;
  final Map<String, List<ProductItem>> _foundProductsCache = {};

  final Set<String> _loadingDetailProdDataIds = {};
  final Map<String, ProductData> _detailProductsDataCache = {};

  final _searchInputFocusNode = FocusNode();
  final _searchInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searching = _searchQuery$
        // FIXME
        .distinct()
        .debounceTime(const Duration(milliseconds: _searchInputDebounceTime))
        .switchMap(_searchStatesStream)
        .listen((searchState) {
          debugPrint(searchState.toString());
          if (!mounted) return;
          setState(() {
            _foundProducts = searchState.items;
            _productsLoading = searchState.loading;
          });
        });

    // _searchInputFocusNode.addListener(() {
    //   if (!_searchInputFocusNode.hasFocus) {
    //     // ...
    //   } else if (_foundProducts.isNotEmpty || _productsLoading) {
    //     // ...
    //   }
    // });
  }

  @override
  void dispose() {
    _searching?.cancel();
    _searchQuery$.close();
    _searchInputCtrl.dispose();
    _searchInputFocusNode.dispose();
    // _hideSearchResPanel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products reference'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchInputCtrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search product',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clear,
                ),
              ),
              onChanged: (query) {
                _searchQuery$.add(query);
                if (query.length < _minInputLettersCnt) {
                  setState(() {
                    _foundProducts = null;
                    _productsLoading = false;
                  });
                }
              },
            ),
          ),
          if (_productsLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_foundProducts == null)
            const Expanded(
              child: Center(
                child: Text(
                  'Start to search to see results',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_foundProducts!.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No products found',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                // shrinkWrap: true,
                itemCount: _foundProducts!.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final product = _foundProducts![i];
                  final loading = _loadingDetailProdDataIds.contains(
                    product.id,
                  );
                  final hasDetails = _detailProductsDataCache.containsKey(
                    product.id,
                  );
                  final productDetails = hasDetails
                      ? _detailProductsDataCache[product.id]
                      : null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasDetails)
                          if (productDetails!.photo != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                productDetails.photo!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            // TODO like in menu
                            Container(
                              width: 64,
                              height: 64,
                              alignment: Alignment.center,
                              child: const Icon(Icons.fastfood),
                            ),
                        if (hasDetails) const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name.capitalize(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (hasDetails)
                                Text(
                                  'protein '
                                  '${productDetails!.proteins.toStringAsFixed(1)}'
                                  'g • fat '
                                  '${productDetails.fats.toStringAsFixed(1)}'
                                  'g • carb '
                                  '${productDetails.carbs.toStringAsFixed(1)}g',
                                  // style: Theme.of(context).textTheme.caption
                                ),
                              if (hasDetails)
                                Text(
                                  '${productDetails!.kcal.toStringAsFixed(0)}'
                                  'kcal / 100g',
                                ),
                            ],
                          ),
                        ),
                        if (hasDetails) const SizedBox(width: 8),
                        if (hasDetails)
                          TextButton.icon(
                            icon: const Icon(Icons.save),
                            iconAlignment: IconAlignment.end,
                            label: const Text('Save'),
                            onPressed: () async =>
                                widget.onSave(productDetails!),
                          )
                        else if (loading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          TextButton.icon(
                            icon: const Icon(Icons.download),
                            iconAlignment: IconAlignment.end,
                            label: const Text('Load'),
                            onPressed: () => _loadProductDetail(product),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Stream<SearchState> _searchStatesStream(String query) {
    if (query.length < _minInputLettersCnt) {
      return Stream.value(const SearchState(loading: false));
    }

    if (_foundProductsCache.containsKey(query)) {
      return Stream.value(
        SearchState(items: _foundProductsCache[query], loading: false),
      );
    }

    final streamCtrl = StreamController<SearchState>();
    final requestStream = Stream.fromFuture(
      widget.api.getProductList(query),
    ).asBroadcastStream();

    var loaderShown = false;
    final showingLoaderSub =
        Stream<void>.value(
              null,
            )
            // if request faster than searchRequestMinTime then theres no loader
            .delay(const Duration(milliseconds: _searchRequestMinTime))
            .takeUntil(requestStream)
            .listen((_) {
              loaderShown = true;
              if (!streamCtrl.isClosed) {
                streamCtrl.add(const SearchState(loading: true));
              }
            });

    Future<void> handleRequestResult(List<ProductItem>? items) async {
      if (loaderShown) {
        await Future<void>.delayed(
          const Duration(milliseconds: _showingLoaderMinTime),
        );
      }
      if (!streamCtrl.isClosed) {
        streamCtrl.add(SearchState(items: items, loading: false));
      }
      await streamCtrl.close();
    }

    final requestStreamSub = requestStream.listen(
      (items) async {
        _foundProductsCache[query] = items;
        await handleRequestResult(items);
        // if (loaderShown) {
        //   await Future<void>.delayed(
        //     const Duration(milliseconds: _showingLoaderMinTime),
        //   );
        // }
        // if (!streamCtrl.isClosed) {
        //   streamCtrl.add(SearchState(items: items, loading: false));
        // }
        // await streamCtrl.close();
      },
      onError: (Object e) async {
        debugPrint('requestStream error: $e');

        await handleRequestResult([]);

        // if (loaderShown) {
        //   await Future<void>.delayed(
        //     const Duration(milliseconds: _showingLoaderMinTime),
        //   );
        // }
        // if (!streamCtrl.isClosed) {
        //   streamCtrl.add(const SearchState(items: [], loading: false));
        // }
        // await streamCtrl.close();
      },
    );
    streamCtrl.onCancel = () async {
      await showingLoaderSub.cancel();
      await requestStreamSub.cancel();
    };
    return streamCtrl.stream;
  }

  Future<void> _loadProductDetail(ProductItem item) async {
    if (_detailProductsDataCache.containsKey(item.id) ||
        _loadingDetailProdDataIds.contains(item.id)) {
      return;
    }

    setState(() {
      _loadingDetailProdDataIds.add(item.id!);
    });

    var data = _detailProductsDataCache[item.id];
    try {
      data = await widget.api.getProductData(item.id!);
      _detailProductsDataCache[item.id!] = data!;
      // debugPrint('!!!product!!!');
      if (mounted) {
        // debugPrint('!!!set state after loading product!!!');
        setState(() {
          _loadingDetailProdDataIds.remove(item.id);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingDetailProdDataIds.remove(item.id);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load product details')),
      );
    }
  }

  void _clear() {
    _searchInputCtrl.clear();
    _searchQuery$.add('');
    setState(() {
      _foundProducts = null;
      _productsLoading = false;
    });
    // _hideSearchResPanel();
    _searchInputFocusNode.requestFocus();
  }
}
