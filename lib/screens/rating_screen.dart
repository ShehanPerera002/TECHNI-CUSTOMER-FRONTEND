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
    
 }