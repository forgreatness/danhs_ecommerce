# danhs_ecommerce

## About
danhs_ecommerce is a Flutter Application that allows the user to browse an ecommerce for items based on the data provided from EBAYS api. This mobile application allows the user to search for an item and acquire detail info on the chosen one.

## How To Use
1. Refer to Flutter for installment
2. Acquire an Ebay Developer Account
3. Use the application key in the production from your account and fill in the empty string on network_utils.dart

## LayOut
### Search Page
- The start of the app will take the user to the Search Page, where there will be an AppBar with an searchdelegate action widget that allow the user to query for an item. The resutls will be return as a ListView and each item will be presented as a Card wiew. The card has a listener that if tap on will take the user to the second page(ItemDetailPage)
### Detail Page
- The detail page will display additional information about the item such as the seller information, the description of item, and additional photos.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
