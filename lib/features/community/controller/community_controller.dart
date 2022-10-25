import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_tutorial/core/constants/constants.dart';
import 'package:reddit_tutorial/core/utils.dart';
import 'package:reddit_tutorial/features/auth/controller/auth_controller.dart';
import 'package:reddit_tutorial/features/community/repository/community_repository.dart';
import 'package:reddit_tutorial/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  return CommunityController(
    communityReposiory: communityRepository,
    ref: ref,
  );
});

class CommunityController extends StateNotifier<bool> {
  final CommunityReposiory _communityReposiory;
  final Ref _ref;
  CommunityController({
    required CommunityReposiory communityReposiory,
    required Ref ref,
  })  : _communityReposiory = communityReposiory,
        _ref = ref,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';

    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final res = await _communityReposiory.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully!');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityReposiory.getUserCommunities(uid);
  }
}
