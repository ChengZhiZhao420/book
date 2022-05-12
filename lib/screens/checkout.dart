
import 'package:checkout_screen_ui/checkout_page.dart';
import 'package:flutter/material.dart';

class CheckOutMain extends StatelessWidget {
  final List cartPrices;
  final List cartID;
  const CheckOutMain({Key? key, required this.cartPrices, required this.cartID}) : super(key: key);

  Future<void> _nativePayClicked(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Native Pay requires setup')));
  }

  Future<void> _cashPayClicked(BuildContext context) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Cash Pay requires setup')));
  }

  List<PriceItem> addItem(){
    List<PriceItem> result = [];
    for(int i = 0; i < cartPrices.length; i++){
      PriceItem temp = PriceItem(name: cartID[i], quantity: 1, totalPriceCents: int.parse(cartPrices[i]["Price"]) * 100);
      result.add(temp);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final demoOnlyStuff = DemoOnlyStuff();

    final GlobalKey<CardPayButtonState> _payBtnKey =
    GlobalKey<CardPayButtonState>();

    Future<void> _creditPayClicked(CardFormResults results) async {
      // you can update the pay button to show somthing is happening
      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.processing);

      // This is where you would implement you Third party credit card
      // processing api
      demoOnlyStuff.callTransactionApi(_payBtnKey);

      // ignore: avoid_print
      print(results);
      // WARNING: you should NOT print the above out using live code
    }

    const String _payToName = 'Magic Vendor';

    const _footer = CheckoutPageFooter(
      // These are example url links only. Use your own links in live code
      privacyLink: 'https://stripe.com/privacy',
      termsLink: 'https://stripe.com/payment-terms/legal',
      note: 'Powered By Not_Stripe',
      noteLink: 'https://stripe.com/',
    );

    Function? _onBack = Navigator.of(context).canPop()
        ? () => Navigator.of(context).pop()
        : null;

    // Put it all together
    return Scaffold(
      appBar: null,
      body: CheckoutPage(
        priceItems: addItem(),
        payToName: _payToName,
        displayNativePay: true,
        onNativePay: () => _nativePayClicked(context),
        displayCashPay: true,
        onCashPay: () => _cashPayClicked(context),
        onCardPay: (results) => _creditPayClicked(results),
        onBack: _onBack,
        payBtnKey: _payBtnKey,
        displayTestData: true,
        footer: _footer,
      ),
    );
  }
}

class DemoOnlyStuff {
  // DEMO ONLY:
  // this variable is only used for this demo.
  bool shouldSucceed = true;

  Future<void> provideSomeTimeBeforeReset(
      GlobalKey<CardPayButtonState> _payBtnKey) async {
    await Future.delayed(const Duration(seconds: 2), () {
      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.ready);
      return;
    });
  }

  Future<void> callTransactionApi(
      GlobalKey<CardPayButtonState> _payBtnKey) async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (shouldSucceed) {
        _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.success);
        shouldSucceed = false;
      } else {
        _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.fail);
        shouldSucceed = true;
      }
      provideSomeTimeBeforeReset(_payBtnKey);
      return;
    });
  }
}