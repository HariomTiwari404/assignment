// lib/screens/product_list_screen.dart

import 'package:a1/models/animation_one.dart';
import 'package:a1/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc/cart_bloc.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductListScreen extends StatefulWidget {
  final ProductRepository repository = ProductRepository();

  ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> _products = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  int _currentPage = 0;
  int _limit = 10; // Dynamic limit

  final GlobalKey _cartIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setDynamicLimit();
      _fetchProducts();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateItemsNeeded(BuildContext context, double itemHeight,
      double spacing, int crossAxisCount) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight =
        screenHeight - appBarHeight - statusBarHeight - spacing * 2;

    // Estimate number of rows that can fit
    int numberOfRows = (availableHeight / (itemHeight + spacing)).floor();

    // Calculate total items needed
    return crossAxisCount * numberOfRows;
  }

  void _setDynamicLimit() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 180).floor();
    crossAxisCount = crossAxisCount < 2 ? 2 : crossAxisCount;

    double spacing = screenWidth * 0.02;
    double childAspectRatio = 0.6;

    double itemHeight = 250;

    int itemsNeeded =
        _calculateItemsNeeded(context, itemHeight, spacing, crossAxisCount);

    if (crossAxisCount * 2 <= itemsNeeded) {
      _limit = itemsNeeded;
    } else {
      _limit = 10;
    }
  }

  Future<void> _fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _hasMore = true;
        _currentPage = 0;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final newProducts = await widget.repository.fetchProducts(
        skip: isRefresh ? 0 : _currentPage * _limit,
        limit: _limit,
      );

      setState(() {
        if (isRefresh) {
          _products.clear();
        }
        _products.addAll(newProducts);
        _currentPage++;
        if (newProducts.length < _limit) {
          _hasMore = false;
        }

        if (!_isRefreshing) {
          _checkIfMoreItemsNeeded();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching products: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  void _checkIfMoreItemsNeeded() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 180).floor();
    crossAxisCount = crossAxisCount < 2 ? 2 : crossAxisCount;

    double spacing = screenWidth * 0.02;
    double childAspectRatio = 0.6;

    double itemHeight = 250;

    int itemsNeeded =
        _calculateItemsNeeded(context, itemHeight, spacing, crossAxisCount);

    if (_products.length < itemsNeeded && _hasMore) {
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = (screenWidth / 180).floor();
    crossAxisCount = crossAxisCount < 2 ? 2 : crossAxisCount;

    double spacing = screenWidth * 0.02;
    double childAspectRatio = 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Catalogue",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final cartItemCount = state.products.length;

              return Stack(
                children: [
                  IconButton(
                    key: _cartIconKey,
                    icon: const Icon(Icons.shopping_cart),
                    color: Colors.black,
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartItemCount > 99 ? '99+' : '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: () => _fetchProducts(isRefresh: true),
        color: Colors.pink,
        backgroundColor: Colors.white,
        animSpeedFactor: 2,
        showChildOpacityTransition: false,
        child: Column(
          children: [
            Expanded(
              child: _products.isEmpty && _isLoading
                  ? _buildShimmerGrid(crossAxisCount, spacing, childAspectRatio)
                  : GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(spacing),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: _products.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _products.length) {
                          final product = _products[index];
                          return ProductCard(
                            product: product,
                            onAddToCart: (Offset position) {
                              _addToCartWithAnimation(product, position);
                            },
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(
      int crossAxisCount, double spacing, double childAspectRatio) {
    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 16, width: 100, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Container(height: 16, width: 60, color: Colors.grey[300]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCartWithAnimation(Product product, Offset startPosition) {
    final RenderBox? cartIconRenderBox =
        _cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    final cartIconPosition =
        cartIconRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    final overlay = Overlay.of(context);

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedAddToCart(
          startPosition: startPosition,
          endPosition: cartIconPosition,
          image: product.thumbnail,
          onAnimationComplete: () {
            overlayEntry?.remove();
          },
        );
      },
    );

    overlay.insert(overlayEntry);

    context.read<CartBloc>().add(AddToCart(product));
  }
}
