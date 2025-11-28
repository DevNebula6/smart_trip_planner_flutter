import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/google_places_remote_datasource.dart';
import 'data/datasources/supabase_remote_datasource.dart';
import 'data/datasources/curated_local_datasource.dart';
import 'data/repositories/discover_repository_impl.dart';
import 'presentation/bloc/discover_bloc.dart';

/// Dependency injection for Discover feature
class DiscoverDependencies {
  static DiscoverBloc createDiscoverBloc() {
    final httpClient = http.Client();
    
    // TODO: Add your Google Places API key here
    // Get it from: https://console.cloud.google.com/google/maps-apis/credentials
    const googleApiKey = 'YOUR_GOOGLE_PLACES_API_KEY'; // TODO: Replace with your key
    
    final googlePlacesDataSource = GooglePlacesRemoteDataSource(
      client: httpClient,
      apiKey: googleApiKey,
    );
    
    // Local JSON datasource (always available)
    final localDataSource = CuratedLocalDataSource();
    
    // Supabase datasource (optional - if Supabase is initialized)
    SupabaseRemoteDataSource? supabaseDataSource;
    try {
      final supabaseClient = Supabase.instance.client;
      supabaseDataSource = SupabaseRemoteDataSource(
        supabaseClient: supabaseClient,
      );
      print('✅ Supabase datasource initialized');
    } catch (e) {
      print('⚠️ Supabase not initialized, will use local cache: $e');
    }
    
    final repository = DiscoverRepositoryImpl(
      googlePlacesDataSource: googlePlacesDataSource,
      supabaseDataSource: supabaseDataSource,
      localDataSource: localDataSource,
      useApi: true, // Enable Google Places API for nearby search
    );
    
    return DiscoverBloc(repository: repository);
  }
  
  /// Provides the Discover Bloc for the widget tree
  static BlocProvider<DiscoverBloc> provide({required Widget child}) {
    return BlocProvider<DiscoverBloc>(
      create: (_) => createDiscoverBloc(),
      child: child,
    );
  }
}
