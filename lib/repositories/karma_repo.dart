import '../models/karma_action.dart';

abstract class KarmaRepository {
  Future<List<KarmaAction>> fetchKarmaActions({String? userId});
  Future<KarmaAction> submitKarmaAction(KarmaAction action);
  Future<KarmaAction> voteOnKarmaAction(String deedId, String validatorId, bool approve);
  Stream<List<KarmaAction>> streamKarmaActions({String? userId});
  Stream<List<KarmaAction>> streamPendingActions();
}
