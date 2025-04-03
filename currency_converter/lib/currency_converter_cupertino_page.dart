import 'package:flutter/cupertino.dart';

class CurrencyConverterCupertinoPage extends StatefulWidget {
  const CurrencyConverterCupertinoPage({super.key});

  @override
  State<CurrencyConverterCupertinoPage> createState() => _CurrencyConverterCupertinoPageState();
}

class _CurrencyConverterCupertinoPageState extends State<CurrencyConverterCupertinoPage> {


  double result = 0;
  TextEditingController convertedTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {


    return CupertinoPageScaffold(
      navigationBar:const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGrey2,
        middle: Text("Currency Converter",style: TextStyle(color: CupertinoColors.white),),
      ),
    backgroundColor: CupertinoColors.systemGrey2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("INR ${result!=0 ? result.toStringAsFixed(3): result}",style:const TextStyle(fontSize: 55,fontWeight: FontWeight.bold,color: CupertinoColors.white),),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CupertinoTextField(
                  keyboardType:const TextInputType.numberWithOptions(decimal: true),
                  style:const TextStyle(color: CupertinoColors.black),
                  controller: convertedTextController,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius:   BorderRadius.circular(5),
                    color: CupertinoColors.white,
                    
                  ),
                  placeholder: "Please enter the amount in USD",
                  prefix:const Icon(CupertinoIcons.money_dollar),
                   

                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CupertinoButton(onPressed: (){
                  setState(() {
                    if (convertedTextController.text.isNotEmpty) {
                      result = (double.tryParse(convertedTextController.text) ?? 0) * 80;
                    } else {
                      result = 0;
                    }
                  });
                
                }, 
                color: CupertinoColors.black ,
                child:const Text("Convert",style: TextStyle(color: CupertinoColors.white),
                ),
                ),
              ),
            ],
          ),
        ),  
     );

  }
}


