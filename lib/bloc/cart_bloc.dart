import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

// Events
abstract class CartEvent {}

class AddToCart extends CartEvent {
  final Product product;
  AddToCart(this.product);
}

class RemoveFromCart extends CartEvent {
  final Product product;
  RemoveFromCart(this.product);
}

class IncrementQuantity extends CartEvent {
  final Product product;
  IncrementQuantity(this.product);
}

class DecrementQuantity extends CartEvent {
  final Product product;
  DecrementQuantity(this.product);
}

class ClearCart extends CartEvent {}

// State
class CartState {
  final List<Product> products;
  final Map<int, int> quantities;

  const CartState({this.products = const [], this.quantities = const {}});

  double get totalPrice => products.fold(
        0,
        (total, product) =>
            total +
            (product.price -
                    (product.price * product.discountPercentage / 100)) *
                (quantities[product.id] ?? 1),
      );

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((product) => product.toJson()).toList(),
      'quantities':
          quantities.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory CartState.fromJson(Map<String, dynamic> json) {
    return CartState(
      products: (json['products'] as List<dynamic>)
          .map((productJson) => Product.fromJson(productJson))
          .toList(),
      quantities: (json['quantities'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), value)),
    );
  }
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    _loadCartData();

    on<AddToCart>((event, emit) async {
      final updatedProducts = List<Product>.from(state.products);
      final updatedQuantities = Map<int, int>.from(state.quantities);

      if (!updatedQuantities.containsKey(event.product.id)) {
        updatedProducts.add(event.product);
      }

      updatedQuantities[event.product.id] =
          (updatedQuantities[event.product.id] ?? 0) + 1;

      final newState = CartState(
        products: updatedProducts,
        quantities: updatedQuantities,
      );
      emit(newState);
      await _saveCartData(newState);
    });

    on<RemoveFromCart>((event, emit) async {
      final updatedProducts = List<Product>.from(state.products)
        ..removeWhere((product) => product.id == event.product.id);
      final updatedQuantities = Map<int, int>.from(state.quantities)
        ..remove(event.product.id);

      final newState = CartState(
        products: updatedProducts,
        quantities: updatedQuantities,
      );
      emit(newState);
      await _saveCartData(newState);
    });

    on<IncrementQuantity>((event, emit) async {
      final updatedQuantities = Map<int, int>.from(state.quantities);
      updatedQuantities[event.product.id] =
          (updatedQuantities[event.product.id] ?? 0) + 1;

      final newState = CartState(
        products: state.products,
        quantities: updatedQuantities,
      );
      emit(newState);
      await _saveCartData(newState);
    });

    on<DecrementQuantity>((event, emit) async {
      final updatedQuantities = Map<int, int>.from(state.quantities);
      if ((updatedQuantities[event.product.id] ?? 0) > 1) {
        updatedQuantities[event.product.id] =
            updatedQuantities[event.product.id]! - 1;
      }

      final newState = CartState(
        products: state.products,
        quantities: updatedQuantities,
      );
      emit(newState);
      await _saveCartData(newState);
    });

    on<ClearCart>((event, emit) async {
      const newState = CartState(
        products: [],
        quantities: {},
      );
      emit(newState);
      await _saveCartData(newState);
    });
  }

  Future<void> _saveCartData(CartState state) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final jsonData = state.toJson();
      final jsonString = jsonEncode(jsonData);
      await prefs.setString('cartData', jsonString);
    } catch (e) {
      print('Error saving cart data: $e');
    }
  }

  Future<void> _loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final cartDataString = prefs.getString('cartData');
      if (cartDataString != null) {
        final cartData = jsonDecode(cartDataString);
        emit(CartState.fromJson(cartData));
      }
    } catch (e) {
      print('Error loading cart data: $e');
    }
  }
}
