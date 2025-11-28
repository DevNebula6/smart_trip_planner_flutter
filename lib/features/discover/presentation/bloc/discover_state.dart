import 'package:equatable/equatable.dart';
import '../../domain/entities/discover_destination.dart';

/// States for discover destinations
abstract class DiscoverState extends Equatable {
  const DiscoverState();
  
  @override
  List<Object?> get props => [];
}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<DiscoverDestination> destinations;
  final DestinationCategory selectedCategory;
  
  const DiscoverLoaded({
    required this.destinations,
    this.selectedCategory = DestinationCategory.all,
  });
  
  @override
  List<Object?> get props => [destinations, selectedCategory];
}

class DiscoverError extends DiscoverState {
  final String message;
  
  const DiscoverError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class DiscoverDetailLoading extends DiscoverState {}

class DiscoverDetailLoaded extends DiscoverState {
  final DiscoverDestination destination;
  
  const DiscoverDetailLoaded(this.destination);
  
  @override
  List<Object?> get props => [destination];
}
