import 'package:flutter/material.dart';
import '/cars/models/car_model.dart';

class CarDetailPage extends StatelessWidget {
  // El widget rep un objecte CarsModel amb totes les dades del cotxe
  final CarsModel car;
  const CarDetailPage({super.key, required this.car});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //fem un appbar per donar els detalls del cotxe
        title: const Text('Detall del Cotxe'),
      ),
      body: Padding( //dins del body definim el padding i fem un child Column per anar posant childrens
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // format del nom i l'estil
            Text(
              '${car.make} ${car.model}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), //un espai per si acas
            Icon(
              car.type == 'SUV'
                  ? Icons.directions_car // si el cotxe es un suv ho mostra, sino mostra un altre
                  : Icons.car_rental,
              size: 64,
            ),
            const SizedBox(height: 16), //un espai per si acas
            //al final posem el botó
            ElevatedButton(
              onPressed: () {//al fer click es mostra la info en un snackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cotxe seleccionat: ${car.make} ${car.model}',//que mostri el make i el model del cotxe
                    ),
                  ),
                );
              },
              child: const Text('Seleccionar cotxe'), //el nom del boto
               ),
          ],
        ),
      ),
    );
  }
}






