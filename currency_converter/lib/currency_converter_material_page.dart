import 'package:flutter/material.dart';

class CurrencyConverterMaterialPage extends StatefulWidget {
  const CurrencyConverterMaterialPage({super.key});

  @override
  State<CurrencyConverterMaterialPage> createState() => _CurrenyConverterMaterialPageState();
}


class _CurrenyConverterMaterialPageState extends State<CurrencyConverterMaterialPage> {

  final border = OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                      style: BorderStyle.solid,
                      strokeAlign: BorderSide.strokeAlignInside
                    ),
                    borderRadius: BorderRadius.circular(5),     
                  );
  double result = 0;
  TextEditingController convertedTextController = TextEditingController();


  @override
  void dispose() {
    convertedTextController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Currency Converter",style: TextStyle(color: Colors.white),),
        elevation: 0,
        centerTitle: true,
      ),
    backgroundColor: Colors.blueGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("INR ${result!=0 ? result.toStringAsFixed(3): result}",style:const TextStyle(fontSize: 55,fontWeight: FontWeight.bold,color: Colors.white),),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  keyboardType:const TextInputType.numberWithOptions(decimal: true),
                  style:const TextStyle(color: Colors.black),
                  controller: convertedTextController,
                  decoration: InputDecoration(
                    hintText: "Please enter the amount in USD",
                    hintStyle: const TextStyle(color: Colors.black),
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                    prefixIconColor: Colors.black,
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: border,
                    enabledBorder: border
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(onPressed: (){
                  setState(() {
                    if (convertedTextController.text.isNotEmpty) {
                      result = (double.tryParse(convertedTextController.text) ?? 0) * 80;
                    } else {
                      result = 0;
                    }
                  });
                
                }, 
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(410, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                child:const Text("Convert",style: TextStyle(color: Colors.white),
                ),
                ),
              ),
            ],
          ),
        ),  
     );

  }
}


