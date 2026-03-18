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

        )
    }
    
 }