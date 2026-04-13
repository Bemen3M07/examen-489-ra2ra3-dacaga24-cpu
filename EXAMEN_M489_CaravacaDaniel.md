# EXAMEN · MÒDUL 489

## Programació de Dispositius Mòbils i Multimèdia

**Unitats Formatives:** RA2 i RA3
**Curs:** 2n DAM · Videojocs
**Data:** 13/04/26
**Durada:** 2 hores

**Alumne/a:** Daniel Caravaca García
**Grup:** DAM

---

## Posada en marxa de l'entorn

Consulta el fitxer **`README.md`** del projecte per a les instruccions completes d'instal·lació i arrencada (Node.js, servidor mock i Flutter).

---

> **Instruccions generals**
>
> - Respon cada pregunta en l'espai indicat (substitueix el text `[Escriu la teva resposta aquí]`).
> - Per a la part de codi, escriu directament en bloc `dart`. No és necessari que el codi compili, però ha de reflectir coneixement real de Flutter/Dart.
> - Tens el codi dels projectes **Cars** i **Phone** com a referència en el teu ordinador. **No pots accedir a internet** durant l'examen.
> - Desa el fitxer i lliura'l amb el nom: `EXAMEN_M489_[el_teu_nom].md`
> - Fes commit i push del .md modificat i de tots els arxius que hagis modificat

---

## BLOC 1 · ARQUITECTURA I CICLE DE VIDA *(RA 2)*

### Pregunta 1.1 – Comunicació entre Widgets *(12 punts)*

Al projecte **Cars**, el widget `CarsPage` gestiona el número de pàgina actual (`_currentPage`) i el passa a `CarsList1`. El widget `ButtonPanel` conté els botons "Anterior" i "Següent".

**a)** A `cars_page.dart`, el widget utilitza el mètode `setState` per gestionar la paginació. Explica:

- Quina és la funció de `setState` i per què cridar-lo fa que la UI es torni a dibuixar.
- Per quin motiu `_loadPage()` fa servir dos crides a `setState` separades (una a l'inici i una al final) en lloc d'una sola.

**Resposta:**

```
setState() notifica a Flutter que l'estat ha canviat i cal tornar a executar build()
La 1a crida activa _isLoading = true per mostrar el CircularProgressIndicator
La 2a crida, un cop arriben les dades, actualitza _cars i desactiva _isLoading = false
Amb una sola crida al final, l'usuari no veuria res durant la càrrega
```

---

### Pregunta 1.2 – Cicle de vida d'un widget amb recursos *(13 punts)*

Al projecte **Camera**, el widget `CameraScreen` utilitza un `CameraController` per gestionar la càmera del dispositiu. Aquest controlador ocupa recursos del sistema (càmera, memòria) i cal alliberar-los correctament.

**a)** Quin mètode del cicle de vida de `State` s'usa a `CameraScreen` per alliberar el `CameraController` quan el widget és destruït? Escriu com es fa i explica per quina raó és imprescindible cridar-lo.

**Resposta:**

```
dispose() s'executa automàticament quan el widget és eliminat de l'arbre
Cal cridar _controller.dispose() per alliberar la càmera i la memòria.
Si no es fa, la càmera es queda bloquejada
Al codi actual de camera_screen.dart aquest mètode no està implementat, suposo que s'hauria d'afegir
```

---

**b)** El `CameraController` s'inicialitza de forma asíncrona a `initState()` i el resultat es guarda a `_initializeControllerFuture`. Respon les preguntes següents:

- Per quin motiu no es pot fer `await` directament a `initState()`?
- Quina millora aporta a l'usuari usar `FutureBuilder` en lloc de bloquejar el fil?
- Com treballen junts `_initializeControllerFuture` i `FutureBuilder`?

**Resposta:**

```
initState() és sync i no pot ser async, per això es guarda el Future sense el await, es a dir que:
_initializeControllerFuture = _controller.initialize()
FutureBuilder escolta el Future i mostra un CircularProgressIndicator mentre que espera,
i quan el Future es finalitza o s'acaba (ConnectionState.done) es mostra el CameraPreview(_controller)
```

---

## BLOC 2 · COMUNICACIÓ, PERSISTÈNCIA I PROVES *(RA 2 — 35 punts)*

### Pregunta 2.1 – Consum d'API i robustesa *(18 punts)*

Analitza el mètode `getCarsPage(int page, int limit)` de `car_http_service.dart`.

Què passaria si el servidor de l'API trigués 60 segons a respondre? L'aplicació quedaria bloquejada per a l'usuari? Per què? Escriu com implementaries un *timeout* de 10 segons a la petició HTTP.

**Resposta:**
```
Sense timeout, si el servidor triga 60s l'app es bloquejaria i l'usuari no podria fer res
Cal afegir .timeout() i capturar TimeoutException amb try/catch.
```

```dart
// Escriu la modificació al getCarsPage aquí:
Future<List<CarsModel>> getCarsPage(int page, int limit) async {
  final offset = (page - 1) * limit;
  // s'ha de fer pels paràmetres (que es salti els 5 primers) paràmetres ?limit=5&offset=5
  final uri = _buildUri('/v1/cars', {'limit': '$limit', 'offset': '$offset'});
  try {
    //es fa la peticio al server de 10s, si triga mes error
    final response = await http
        .get(uri, headers: _headers)
        .timeout(
          const Duration(seconds: 10),
          // Si passa el temps, llancem TimeoutException amb un missatge
          onTimeout: () => throw TimeoutException('Timeout de 10 segons.'),
        );
    // si el servidor respon be, convertim el json a una llista
    if (response.statusCode == 200) {
      return CarsModel.listFromJsonString(response.body);
    }
    // pot ser que el servidor respongui pero doni error (en menys de 10s)
    throw Exception('Error ${response.statusCode}');
  } on TimeoutException catch (e) {
    // mostrem error de timeout si no respon en menys de 10s
    throw Exception('Timeout: ${e.message}');
  } on SocketException {
    // per si no hi ha conexió saber-ho
    throw Exception('Sense connexió a internet.');
  }
}
```

---

### Pregunta 2.2 – Models de dades  *(17 punts)*

Analitza el constructor `factory CarsModel.fromMapToCarObject(Map<String, dynamic> json)` de `car_model.dart`.

**a)** Imagina que l'API retorna per error el camp `year` com a `String` en lloc d'`int` (per exemple, `"2021"` en lloc de `2021`). El codi actual fallaria. Escriu com resoldries el problema.

**Resposta:**

```
El codi actual fa: json['year'] as int
hauria de fallar si rep "2021" com a String
Una solució és utilitzar int.tryParse() que accepta tant int com String
Si el parsing falla, l'operador ?? retorna 0 com a valor per defecte
```

---

**b)** Al fitxer `class_model_test.dart`, el test utilitza un `const jsonString` amb un JSON escrit a mà en lloc de fer una petició real a l'API de RapidAPI. Explica per quin motiu és millor simular el JSON en un test unitari.

**Resposta:**

```
Perque es comprova només la lògica
Els tests amb dades reals depenen d'una API externa que funcioni, si no funciona fallarà
Així els tests són ràpids i funcionen sense connexió a internet, es poden fer moltes vegades sense dependre de la API
```

---

## BLOC 3 · IMPLEMENTACIÓ PRÀCTICA *(RA 3 — 30 punts)*

### Exercici – Widget de detall amb dades remotes

Imagina que volem crear una pantalla de detall per a cada cotxe del projecte Cars. Implementa el mètode `build` d'un widget `StatelessWidget` anomenat `CarDetailPage` que compleixi els requisits següents:

1. Rep un paràmetre `final CarsModel car` al constructor.
2. Mostra el **make** i el **model** del cotxe com a títol destacat (`Text` amb estil gran i negreta).
3. Mostra una **icona diferent** depenent del `type` del cotxe:
   - Si el `type` és `'SUV'`, mostra `Icons.directions_car`.
   - Per qualsevol altre tipus, mostra `Icons.car_rental`.
4. Afegeix un botó `ElevatedButton` que, quan es premi, mostri un `SnackBar` amb el text: `"Cotxe seleccionat: [make] [model]"`.

```dart
// Escriu el teu codi aquí:

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
              //... i aqui es va tancant tot
```

---

**Ampliació (nivell Expert):** Afegeix un `FutureBuilder` que cridi al mètode `CarHttpService().getCarsPage(1, 5)` i mentre espera les dades mostri un `CircularProgressIndicator`. Quan les dades estiguin llestes, mostra un `ListView.builder` amb el `make` de cada cotxe. Si hi hagués un error, mostra un `Text` en color vermell amb el missatge de l'error.

```dart
//Escriu la teva ampliació aquí:
```

---

## BLOC 4 · EXTENSIÓ DEL SERVEI HTTP *(RA 2 — 10 punts)*

### Exercici 4.1 – Mètode parametritzat a `CarHttpService` *(10 punts)*

El servidor mock local té disponible un  endpoint de cerca:

```
GET http://localhost:8080/v1/cars/search?make=Toyota&model=Corolla
```

- El paràmetre `make` filtra per marca (coincidència parcial, insensible a majúscules).
- El paràmetre `model` filtra per model (coincidència parcial, insensible a majúscules).
- Tots dos paràmetres són opcionals: si no s'envien, retorna tots els cotxes.

Exemples vàlids:

- `/v1/cars/search?make=Toyota` → tots els Toyota
- `/v1/cars/search?model=X5` → tots els cotxes amb "X5" al model
- `/v1/cars/search?make=BMW&model=X` → BMW amb "X" al model

**Implementa** el mètode `getCarsByFilter` a la classe `CarHttpService` existent, seguint el mateix patrons que `getCarsPage`:
```
He implementat el mètode, per valorar si funciona he utilitzat les següents url al buscador (com la anterior):
http://localhost:8080/v1/cars/search?make=Toyota
http://localhost:8080/v1/cars/search?make=BMW&model=X
```

Requisits:

1. Utilitza el mètode privat `_buildUri(String path, Map<String, String> queryParams)` ja existent.
2. Només afegeix els paràmetres `make` i/o `model` al mapa si el valor no és `null` ni buit (`isEmpty`).
3. Gestiona errors i timeout amb el mateix mecanisme que `getCarsPage`.

**Resposta:**

```dart
Future<List<CarsModel>> getCarsByFilter({
  String? make,
  String? model,
}) async {

  // fem un mapa buit nomes amb els parametres qeu tenen valor
  final Map<String, String> queryParams = {};

  // si make no es null ni buit ho afegim
  if (make != null && make.isNotEmpty) queryParams['make'] = make;

  // si model no es null ni buit ho afegim
  if (model != null && model.isNotEmpty) queryParams['model'] = model;

  // amb els parametres que tenim fem la uri
  final uri = _buildUri('/v1/cars/search', queryParams);

  try {
    // la peticio igual que getCarsPage, amb 10s de timeout
    final response = await http.get(uri, headers: _headers).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Timeout de 10 segons.'),
        );

    // si funciona convertim el json en una llista
    if (response.statusCode == 200) {
      return CarsModel.listFromJsonString(response.body);
    }
    // si el server no respon, o tot i que respongui no funciona o si no hi ha conexió a internet
    throw Exception('Error ${response.statusCode}');
  } on TimeoutException catch (e) {
    throw Exception('Timeout: ${e.message}');
  } on SocketException {
    throw Exception('Sense connexió a internet.');
  }
} //i crec que aquí ja es tanca bé
```

---

## Resum de l'examen

| Bloc | RA | Punts màxims |
|------|----|:------------:|
| Bloc 1 – Arquitectura i Cicle de vida | RA 2 | 25 |
| Bloc 2 – Comunicació, Persistència i Proves | RA 2  | 35 |
| Bloc 3 – `CarDetailPage` (base) | RA 3 | 20 |
| Bloc 3 – Ampliació `FutureBuilder`  | RA 3 | 10 |
| Bloc 4 – Extensió del servei HTTP | RA 2 | 10 |
| **TOTAL** | | **100** |

---
