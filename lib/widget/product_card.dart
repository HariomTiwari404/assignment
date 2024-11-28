import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final void Function(Offset position) onAddToCart;
  final bool isLoading;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        final imageHeight = cardHeight * 0.5;
        final buttonPaddingVertical = cardHeight * 0.02;
        final buttonPaddingHorizontal = cardWidth * 0.1;
        final buttonBorderRadius = cardWidth * 0.02;
        final buttonFontSize = cardHeight * 0.05;

        final titleFontSize = cardHeight * 0.07;
        final priceFontSize = cardHeight * 0.045;
        final originalPriceFontSize = cardHeight * 0.035;
        final discountFontSize = cardHeight * 0.035;

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardWidth * 0.02),
          ),
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(cardWidth * 0.02),
                    ),
                    child: isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: Colors.grey[300],
                            ),
                          )
                        : Image.network(
                            product.thumbnail,
                            height: imageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: imageHeight,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                  ),
                  if (!isLoading)
                    Positioned(
                      bottom: cardHeight * 0.02,
                      right: cardWidth * 0.02,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(buttonBorderRadius),
                        child: InkWell(
                          onTapDown: (details) {
                            onAddToCart(details.globalPosition);
                          },
                          borderRadius:
                              BorderRadius.circular(buttonBorderRadius),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: buttonPaddingVertical,
                              horizontal: buttonPaddingHorizontal,
                            ),
                            child: Center(
                              child: Text(
                                "Add",
                                style: TextStyle(
                                  fontSize: buttonFontSize,
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (!isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardWidth * 0.04,
                    vertical: cardHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title
                      AutoSizeText(
                        product.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                        maxLines: 2,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: cardHeight * 0.01),
                      // Brand Name
                      AutoSizeText(
                        product.brand ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: priceFontSize, // Smaller than title font
                          color: Colors.grey[600], // Subtle color
                        ),
                        maxLines: 1,
                        minFontSize: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: cardHeight * 0.01),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 0,
                            child: Text(
                              "₹${product.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: originalPriceFontSize,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 0,
                            child: Text(
                              " ₹${(product.price - (product.price * product.discountPercentage / 100)).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: priceFontSize,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: cardHeight * 0.02),
                      Text(
                        "${product.discountPercentage.toStringAsFixed(2)}% OFF",
                        style: TextStyle(
                          fontSize: discountFontSize,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
