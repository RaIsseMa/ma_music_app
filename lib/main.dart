import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ma_music_app/pages/search_page.dart';
import 'package:ma_music_app/html_parse.dart';

void main() {
  runApp(const MaterialApp(home: Start(),));
}

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
            'Musically',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold
            ),
        ),
        backgroundColor: const Color(0xff272435),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const SearchPage()));
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff272435)
            ),

          ),
          _buildBottomNavigation()
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() => Align(
    alignment: FractionalOffset.bottomCenter,
    child: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Opacity(
          opacity: 1,
          child: BottomNavigationBar(
            elevation: 3,
            backgroundColor: const Color(0x00ffffff),
            unselectedIconTheme: const IconThemeData(
              color: Colors.white,
            ),
            unselectedItemColor: Colors.white,
            selectedIconTheme: const IconThemeData(
              color: Color(0xffff2851),
              size: 30
            ),
            selectedItemColor: const Color(0xffff2851),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.music_note_outlined),
                  label: "Music"
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: "Favorite"
              )
            ],
          ),
        ),
      ),
    ),
  );
}

