import 'dart:io';
import 'package:flutter/material.dart';

// Package used to create star rating widget
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

//Package used to pick images from gallery or camera
import 'package:image_picker/image_picker.dart';

//Rating screen widgets 
 class RatingScreen extends StatefulWigdget{
    const RatingScreen({Super.key});

    @override 
    State<RatingScreen> createState() => _RatingScreenState();
 }
 
 class _RatingScreenState extends State<RatingScreen>{

    // deafult rating value 
    double rating = 4;

    final TextEditingController commentController = TextEditingController();
    final ImagePicker picker = ImagePicker();

    List<File> images = [];

    //Function to pick image from gallery 
    Future pickImage() async{

        final XFile? image = 
            await picker.pickImage (Source: ImageSource.gallery);

        if (image != null){
            setState((){
                images.add(File(image.path));
            });
        }
    }

    @override 
    Widget build (BuildContext context){

        return Scaffold(

            //App bar at the top 
            appBar: AppBar(
                title: const Text("Rate Service"),
                centerTitle: true,
            ),

             
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            /

            const CircleAvatar(
              radius: 40,

              // Worker profile image
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/150?img=3",
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Saman Perera",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "Professional Plumber",
              style: TextStyle(
                color: Colors.blue,
              ),
            ), 

            const SizedBox(height: 30),

            //Rating card

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Column(
                children: [

                  /// Rating title
                  const Text(
                    "How was your service?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                 
                  RatingBar.builder(
                    
                    initialRating: rating,
                    minRating: 1,
                    itemCount: 5,
                    itemSize: 35,

                    // Star icon
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),

                    // When user changes rating
                    onRatingUpdate: (value) {

                      setState(() {
                        rating = value;
                      });

                    },
                  ),

                  const SizedBox(height: 10),

                  
                  Text(
                    rating >= 4
                        ? "Great"
                        : rating >= 3
                            ? "Good"
                            : "Poor",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  )

                ],
              ),
            ),

             const SizedBox(height: 25),

            
            // COMMENT SECTION
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Comments (Optional)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: commentController,
              maxLines: 4,

              decoration: InputDecoration(
                hintText: "Tell us more about your experience...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

             const SizedBox(height: 20),

            //IMAGE UPLOAD BUTTON

            Row(
              children: [
                ElevatedButton.icon(

                  onPressed: pickImage,

                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Add Photo"),
                ),
              ],
            ),


        )
    }
    
 }