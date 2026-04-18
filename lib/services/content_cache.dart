import '../models/album.dart';
import '../models/user_profile.dart';

class _Entry<T> {
  final T data;
  final DateTime stamp;
  _Entry(this.data) : stamp = DateTime.now();

  bool get fresh => DateTime.now().difference(stamp) < ContentCache.ttl;
}

class ContentCache {
  ContentCache._();
  static final ContentCache instance = ContentCache._();

  static const ttl = Duration(minutes: 3);

  _Entry<List<Album>>? _albums;
  final Map<int, _Entry<Album>> _details = {};
  _Entry<List<RankingEntry>>? _leaderboard;
  _Entry<List<Friend>>? _friends;

  List<Album>? get albums => _albums?.fresh == true ? _albums!.data : null;
  set albums(List<Album>? v) => _albums = v != null ? _Entry(v) : null;

  Album? detail(int id) {
    final e = _details[id];
    return e?.fresh == true ? e!.data : null;
  }

  void setDetail(Album a) => _details[a.id] = _Entry(a);

  List<RankingEntry>? get leaderboard =>
      _leaderboard?.fresh == true ? _leaderboard!.data : null;
  set leaderboard(List<RankingEntry>? v) =>
      _leaderboard = v != null ? _Entry(v) : null;

  List<Friend>? get friends =>
      _friends?.fresh == true ? _friends!.data : null;
  set friends(List<Friend>? v) =>
      _friends = v != null ? _Entry(v) : null;

  void invalidateAlbum(int id) {
    _details.remove(id);
    _albums = null;
  }

  void clear() {
    _albums = null;
    _details.clear();
    _leaderboard = null;
    _friends = null;
  }
}
