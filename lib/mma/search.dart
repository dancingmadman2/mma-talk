import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/styles.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

TextEditingController _searchController = TextEditingController();
FocusNode focusNode = FocusNode();

class _SearchState extends State<Search> {
  @override
  void initState() {
    focusNode.requestFocus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Column(
          children: [
            TextFormField(
              cursorColor: secondary,
              controller: _searchController,
              focusNode: focusNode,
              keyboardType: TextInputType.text,
              autofocus: false,
              textAlignVertical: TextAlignVertical.center,
              style: eventTitleWhite,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: secondary,
                ),
                hintText: 'Search UFC Events/Fighters',
                hintStyle: GoogleFonts.bebasNeue(
                  color: secondary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Search // in development',
              style: filter,
            ),
            const Icon(
              CupertinoIcons.hammer,
              color: Colors.white,
              size: 35,
            )
          ],
        ),
      ),
    );
  }
}
