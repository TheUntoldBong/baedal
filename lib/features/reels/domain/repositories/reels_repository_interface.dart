import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/features/reels/domain/models/reel_model.dart';
import 'package:stackfood_multivendor/interface/repository_interface.dart';

abstract class ReelsRepositoryInterface extends RepositoryInterface {
  @override
  Future<ReelListModel?> getList({int? offset, int? limit, DataSourceEnum source = DataSourceEnum.local});

  Future<ReelStatsModel?> getReelStats(int reelId);

  Future<ReelLikeResponseModel> toggleReelLike(int reelId);

  Future<bool> visitReel(int reelId);
}

class ReelLikeResponseModel {
  final ResponseModel response;
  final bool? isLiked;
  final int? totalLikes;

  ReelLikeResponseModel({required this.response, this.isLiked, this.totalLikes});
}
