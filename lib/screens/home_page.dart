import 'package:flutter/material.dart';
import '../models/restroom.dart';
import '../services/restroom_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RestroomService _restroomService = RestroomService();
  final TextEditingController _searchController = TextEditingController();
  List<Restroom> _restrooms = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _itemsPerPage = 10;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadRestrooms();
  }

  Future<void> _loadRestrooms({String query = '', bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
      });
    }

    if (!_hasMoreData && !isRefresh) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final restrooms = await _restroomService.searchRestrooms(
        query: query,
        page: _currentPage,
        perPage: _itemsPerPage,
        offset: (_currentPage - 1) * _itemsPerPage,
      );

      setState(() {
        if (isRefresh) {
          _restrooms = restrooms;
        } else {
          _restrooms.addAll(restrooms);
        }
        _hasMoreData = restrooms.length == _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchRestrooms() async {
    final query = _searchController.text.trim();
    await _loadRestrooms(query: query, isRefresh: true);
  }

  Future<void> _onRefresh() async {
    final query = _searchController.text.trim();
    await _loadRestrooms(query: query, isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restroom Finder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search restrooms (e.g., san francisco)...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchRestrooms(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchRestrooms,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          
          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // Results list
          Expanded(
            child: _restrooms.isEmpty && !_isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eleven_mp,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No restrooms found',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Try searching for a location',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      itemCount: _hasMoreData && _restrooms.isNotEmpty
                          ? _restrooms.length + 1
                          : _restrooms.length,
                      itemBuilder: (context, index) {
                        if (index == _restrooms.length) {
                          // Loading indicator for "load more"
                          return _isLoading && index > 0
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Container();
                        }

                        final restroom = _restrooms[index];
                        return _buildRestroomCard(restroom);
                      },
                    ),
                  ),
          ),
        ],
      ),
      // Load more button when not loading and there's more data
      floatingActionButton: _hasMoreData && !_isLoading
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _currentPage++;
                });
                _loadRestrooms(query: _searchController.text.trim());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRestroomCard(Restroom restroom) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restroom.name.isNotEmpty ? restroom.name : 'Unnamed Restroom',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (restroom.ada)
                  const Icon(Icons.accessible, color: Colors.green, size: 18),
                if (restroom.unisex)
                  const Icon(Icons.transgender, color: Colors.purple, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            if (restroom.street.isNotEmpty)
              Text(
                restroom.street,
                style: const TextStyle(color: Colors.grey),
              ),
            if (restroom.city.isNotEmpty || restroom.state.isNotEmpty)
              Text(
                '${restroom.city}${restroom.city.isNotEmpty ? ', ' : ''}${restroom.state}',
                style: const TextStyle(color: Colors.grey),
              ),
            if (restroom.country.isNotEmpty)
              Text(
                restroom.country,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 8),
            if (restroom.directions.isNotEmpty)
              Text(
                restroom.directions,
                style: const TextStyle(fontSize: 14),
              ),
            if (restroom.comment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Comment: ${restroom.comment}',
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.thumb_up, size: 16),
                Text(' ${restroom.upvote}'),
                const SizedBox(width: 16),
                const Icon(Icons.thumb_down, size: 16),
                Text(' ${restroom.downvote}'),
                if (restroom.changingTable.isNotEmpty && restroom.changingTable != 'f')
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Icon(Icons.child_care, size: 16, color: Colors.orange),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}