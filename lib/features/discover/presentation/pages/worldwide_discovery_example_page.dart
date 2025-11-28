import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:smart_trip_planner_flutter/features/discover/presentation/bloc/discover_event.dart';
import 'package:smart_trip_planner_flutter/features/discover/presentation/bloc/discover_state.dart';
import 'package:smart_trip_planner_flutter/features/discover/domain/entities/discover_destination.dart';

/// Example page demonstrating Phase 2 implementation
/// Shows how to use the 3-tier fallback system for worldwide discovery
class WorldwideDiscoveryExamplePage extends StatefulWidget {
  const WorldwideDiscoveryExamplePage({super.key});

  @override
  State<WorldwideDiscoveryExamplePage> createState() =>
      _WorldwideDiscoveryExamplePageState();
}

class _WorldwideDiscoveryExamplePageState
    extends State<WorldwideDiscoveryExamplePage> {
  DestinationCategory _selectedCategory = DestinationCategory.all;

  @override
  void initState() {
    super.initState();
    // Load worldwide destinations on page load
    context.read<DiscoverBloc>().add(
          LoadWorldwideDestinations(
            category: _selectedCategory,
            limit: 50,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worldwide Discovery (Phase 2)'),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          // Top rated button
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              context.read<DiscoverBloc>().add(
                    const LoadTopRatedDestinations(limit: 10),
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          _buildCategoryFilter(),
          
          // Destinations list
          Expanded(
            child: BlocBuilder<DiscoverBloc, DiscoverState>(
              builder: (context, state) {
                if (state is DiscoverLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is DiscoverError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DiscoverBloc>().add(
                                  LoadWorldwideDestinations(
                                    category: _selectedCategory,
                                  ),
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is DiscoverLoaded) {
                  final destinations = state.destinations;
                  
                  if (destinations.isEmpty) {
                    return const Center(
                      child: Text('No destinations found'),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DiscoverBloc>().add(
                            LoadWorldwideDestinations(
                              category: _selectedCategory,
                            ),
                          );
                    },
                    child: ListView.builder(
                      itemCount: destinations.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final destination = destinations[index];
                        return _buildDestinationCard(destination);
                      },
                    ),
                  );
                }
                
                return const Center(
                  child: Text('Pull down to load destinations'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: DestinationCategory.values.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  context.read<DiscoverBloc>().add(
                        LoadWorldwideDestinations(
                          category: category == DestinationCategory.all
                              ? null
                              : category,
                        ),
                      );
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDestinationCard(DiscoverDestination destination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (destination.primaryImageUrl != null)
            Image.network(
              destination.primaryImageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 64),
                );
              },
            ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and country
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        destination.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (destination.hiddenScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              destination.hiddenScore!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Country
                if (destination.country != null)
                  Text(
                    '📍 ${destination.country}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Description
                if (destination.description != null)
                  Text(
                    destination.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 12),
                
                // Best season and difficulty
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (destination.bestSeason != null)
                      Chip(
                        label: Text('🌤️ ${destination.bestSeason}'),
                        backgroundColor: Colors.blue[50],
                      ),
                    if (destination.difficulty != null)
                      Chip(
                        label: Text('💪 ${destination.difficulty}'),
                        backgroundColor: Colors.green[50],
                      ),
                    if (destination.budgetLevel != null)
                      Chip(
                        label: Text('💰 ${destination.budgetLevel}'),
                        backgroundColor: Colors.orange[50],
                      ),
                    if (destination.visitDuration != null)
                      Chip(
                        label: Text(
                          '📅 ${destination.visitDuration} days',
                        ),
                        backgroundColor: Colors.purple[50],
                      ),
                  ],
                ),
                
                // Tags
                if (destination.tags != null && destination.tags!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: destination.tags!
                          .take(5)
                          .map(
                            (tag) => Text(
                              '#$tag',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                
                // Travel tips preview
                if (destination.travelTips != null &&
                    destination.travelTips!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 Travel Tips:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• ${destination.travelTips![0]}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (destination.travelTips!.length > 1)
                          Text(
                            '+ ${destination.travelTips!.length - 1} more tips',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
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
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String query = '';
        return AlertDialog(
          title: const Text('Search Destinations'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter destination name or keyword',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => query = value,
            onSubmitted: (value) {
              Navigator.pop(dialogContext);
              if (value.isNotEmpty) {
                context.read<DiscoverBloc>().add(
                      SearchWorldwideDestinations(
                        query: value,
                        category: _selectedCategory == DestinationCategory.all
                            ? null
                            : _selectedCategory,
                      ),
                    );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (query.isNotEmpty) {
                  context.read<DiscoverBloc>().add(
                        SearchWorldwideDestinations(
                          query: query,
                          category: _selectedCategory == DestinationCategory.all
                              ? null
                              : _selectedCategory,
                        ),
                      );
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}

/// Add this to your main.dart or app routes to test:
///
/// ```dart
/// MaterialApp(
///   home: DiscoverDependencies.provide(
///     child: const WorldwideDiscoveryExamplePage(),
///   ),
/// )
/// ```
