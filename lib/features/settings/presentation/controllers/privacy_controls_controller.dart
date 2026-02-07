import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PrivacyLevel {
  public,
  friendsOnly,
  private
}

class PrivacyControlsState {
  final PrivacyLevel phoneNumber;
  final PrivacyLevel email;
  final PrivacyLevel location;
  final PrivacyLevel website;
  final PrivacyLevel businessLinks;
  final bool isLoading;

  const PrivacyControlsState({
    this.phoneNumber = PrivacyLevel.private,
    this.email = PrivacyLevel.friendsOnly,
    this.location = PrivacyLevel.public,
    this.website = PrivacyLevel.public,
    this.businessLinks = PrivacyLevel.public,
    this.isLoading = false,
  });

  PrivacyControlsState copyWith({
    PrivacyLevel? phoneNumber,
    PrivacyLevel? email,
    PrivacyLevel? location,
    PrivacyLevel? website,
    PrivacyLevel? businessLinks,
    bool? isLoading,
  }) {
    return PrivacyControlsState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      location: location ?? this.location,
      website: website ?? this.website,
      businessLinks: businessLinks ?? this.businessLinks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrivacyControlsController extends StateNotifier<PrivacyControlsState> {
  PrivacyControlsController() : super(const PrivacyControlsState());

  // Simulating API call
  Future<void> updatePrivacy({
    PrivacyLevel? phoneNumber,
    PrivacyLevel? email,
    PrivacyLevel? location,
    PrivacyLevel? website,
    PrivacyLevel? businessLinks,
  }) async {
    // Optimistic update
    state = state.copyWith(
      phoneNumber: phoneNumber,
      email: email,
      location: location,
      website: website,
      businessLinks: businessLinks,
    );
    
    // Simulate network delay if needed, or actual API call here
    // await Future.delayed(const Duration(milliseconds: 500));
  }
}

final privacyControlsProvider = StateNotifierProvider<PrivacyControlsController, PrivacyControlsState>((ref) {
  return PrivacyControlsController();
});
