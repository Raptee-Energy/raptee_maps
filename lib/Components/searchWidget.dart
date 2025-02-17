import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final List<dynamic> suggestions;
  final Function(String) onSearchChanged;
  final Function(dynamic) onSuggestionSelected;

  const SearchWidget({super.key,
    required this.searchController,
    required this.suggestions,
    required this.onSearchChanged,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search Places',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: onSearchChanged,
        ),
        if (suggestions.isNotEmpty)
          Container(
            color: Colors.white,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]['description']),
                  onTap: () => onSuggestionSelected(suggestions[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}
