// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_with_firebase/LogInPage.dart';
import 'package:flutter_with_firebase/bottomNavPages.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
import 'package:curved_carousel/curved_carousel.dart';
import 'package:coverflow/coverflow.dart';
import 'bottomNavPages.dart';
class Plant {
  final String id;
  final String name;
  final String category;
  final String size;
  final String difficulty;
  final String description;
  final double price;
  final int humidity;
  final double height;
  final String temperature;
  final String imageUrl;

  Plant({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.difficulty,
    required this.description,
    required this.price,
    required this.humidity,
    required this.height,
    required this.temperature,
    required this.imageUrl,
  });

  factory Plant.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Plant(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      size: data['size'] ?? '',
      difficulty: data['difficulty'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? 0.0,
      humidity: data['humidity'] ?? 0,
      height: data['height'] ?? 0.0,
      temperature: data['temperature'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex=0;
 
  // Add item to favorites
  Future<void> addToFavorites(String plantId) async {
    final userFavorites = _firestore.collection('favorites').doc('user1'); // Use user-specific ID
    final snapshot = await userFavorites.get();

    if (!snapshot.exists) {
      await userFavorites.set({'plants': ['id']});
    } else {
      final plants = List<String>.from(snapshot.data()?['plants'] ?? []);
      if (!plants.contains(plantId)) {
        plants.add(plantId);
        await userFavorites.update({'plants': plants});
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to Favorites!')),
    );
  }

  // Add item to cart
  Future<void> addToCart(String plantId) async {
    final userCart = _firestore.collection('cart').doc('user1'); // Use user-specific ID
    final snapshot = await userCart.get();

    if (!snapshot.exists) {
      await userCart.set({'plants': [plantId]});
    } else {
      final plants = List<String>.from(snapshot.data()?['plants'] ?? []);
      plants.add(plantId);
      await userCart.update({'plants': plants});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to Cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('appBarTitle'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),

      body: 
 ListView(
        children: [
         
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

         Container(
  height: MediaQuery.of(context).size.height * 0.5,
  child: StreamBuilder(
    stream: _firestore.collection('plants').snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          childAspectRatio: 0.75, // Adjust for desired height-to-width ratio
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final plant = snapshot.data!.docs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlantDetailsScreen(
                    plant: Plant.fromFirestore(plant),
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        plant['imageUrl'], // Image URL from Firestore
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Icon(Icons.broken_image, size: 50));
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      plant['name'], // Name from Firestore
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '₹${plant['price']}', // Price from Firestore
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                     
                        IconButton(
                        icon: 
                         Icon(Icons.shopping_cart),
                        onPressed: () {
                          // Add to favorites logic
                           addToCart(plant.id);
                        },
                      ),
                      SizedBox(width: 55,),
                      IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Add to favorites logic
                             addToFavorites(plant.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
),
      
           

        ],
      ),
     bottomNavigationBar: Stack(
  clipBehavior: Clip.none,
  children: [
    Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          //Todo 
          
        },
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
               onTap: () {
     Navigator.push( context, MaterialPageRoute(builder: (context) => CartPage()),
                );
                },
              child: Icon(Icons.shopping_cart)),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.pop(context);
      //Navigator.push( context, MaterialPageRoute(builder: (context) => HomeScreen()),);
                },
              child: Icon(Icons.home)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
               onTap: () {
     Navigator.push( context, MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
                },
              child: Icon(Icons.favorite_border)),
            label: 'Favorites',
          ),
        ],
      ),
    ),
    
  ],
),

    );
  }
}

class PlantCard extends StatefulWidget {
  final Plant plant;
  final VoidCallback onCardTap;

  PlantCard({required this.plant, required this.onCardTap});

  @override
  _PlantCardState createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
     width: 100,
     margin: EdgeInsets.all(5),
      child: Card(
        elevation: 20,
         semanticContainer: true,
         clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
         // side: BorderSide(color: Colors.white70, width: 1),
      borderRadius: BorderRadius.circular(40),
        ),
        color: Color.fromARGB(159, 146, 239, 115),
        child: GestureDetector(onTap:widget.onCardTap,
        child: Container(
         // padding: EdgeInsets.all(5),
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(children: [
             // SizedBox(width: 40,),
            CircleAvatar(backgroundImage: NetworkImage(widget.plant.imageUrl),maxRadius:40,) ,
             //SizedBox(height: 5,),
             Text(widget.plant.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize:20),),
                    ],),
          ),),),
        //margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        // child: ListTile(
         
        //    leading:CircleAvatar(backgroundImage: NetworkImage(widget.plant.imageUrl),maxRadius:30,) ,
        //   //leading: Image.network(widget.plant.imageUrl),
        //   title: Text(widget.plant.name),
        //   //subtitle: Text(widget.plant.category),
        //   //trailing: Text('\$${widget.plant.price.toStringAsFixed(2)}'),
        //   onTap: widget.onCardTap, 
        // // Use the callback passed from HomeScreen
        // ),
      ),
    );
  }
}

class PlantDetailsScreen extends StatefulWidget {
  final Plant plant;

  PlantDetailsScreen({required this.plant});

  @override
  _PlantDetailsScreenState createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
   Future<void> addToCart(String plantId) async {
    final userCart = _firestore.collection('cart').doc('user1'); // Use user-specific ID
    final snapshot = await userCart.get();

    if (!snapshot.exists) {
      await userCart.set({'plants': [plantId]});
    } else {
      final plants = List<String>.from(snapshot.data()?['plants'] ?? []);
      plants.add(plantId);
      await userCart.update({'plants': plants});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to Cart!')),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Information'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://i.pinimg.com/736x/2a/22/6b/2a226ba87e1c1059216973ebb96d358f.jpg'),
            fit: BoxFit.fill,
            opacity: 0.7,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.plant.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.water_drop, color: Colors.yellow, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  '${widget.plant.humidity}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.height, color: Colors.yellow, size: 30),
                                SizedBox(width: 10),
                                Text(
                                  '${widget.plant.height}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.thermostat, color: Colors.yellow, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  '${widget.plant.temperature}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 70,),
                      Center(
                        child: CircleAvatar(
                          maxRadius: 70,
                          backgroundImage: NetworkImage(widget.plant.imageUrl),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 500,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price',
                                style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$ ${widget.plant.price}',
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Category',
                                style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.plant.category,
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Size',
                                style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.plant.size,
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.plant.description,
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Difficulty',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.plant.difficulty,
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                 addToCart(widget.plant.id);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            child: Text('Add to cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}