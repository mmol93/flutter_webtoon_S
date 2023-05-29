import 'dart:convert';
// 해당 패키지를 사용할 떄 http라는 이름을 사용하게 한다.
import 'package:http/http.dart' as http;
import 'package:webtoon_naver/models/webtoon_detail_model.dart';
import 'package:webtoon_naver/models/webtoon_episode_model.dart';
import 'package:webtoon_naver/models/webtoon_model.dart';

class ApiService {
  final String baseUrl = "https://webtoon-crawler.nomadcoders.workers.dev";
  final String today = "today";
  List<WebtoonModel> webtoonInstances = [];

  // 오늘의 웹툰 데이터를 가져온다.
  // 비동기 작업을 위해 async 함수로 만든다.
  Future<List<WebtoonModel>> getTodaysToons() async {
    final url = Uri.parse("$baseUrl/$today");
    // Future 클래스 형태로 비동기적으로 값을 기다려서 받을 경우에는 await를 사용한다.
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // 받은 데이터를 JSON으로 디코딩 한다.
      final List<dynamic> webtoons = jsonDecode(response.body);
      for (var webtoon in webtoons) {
        webtoonInstances.add(WebtoonModel.fromJson(webtoon));
      }
      return webtoonInstances;
    }
    throw Error();
  }

  // 특정 웹툰에 대한 설명을 가져온다.
  Future<WebtoonDetailModel> getToonById(String id) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final webtoon = jsonDecode(response.body);
      return WebtoonDetailModel.fromJson(webtoon);
    }
    throw Error();
  }

  // 해당 웹툰의 최근 에피소드 데이터를 가져온다.
  Future<List<WebtoonEpisodeModel>> getLatestEpisodesById(String id) async {
    final url = Uri.parse("$baseUrl/$id/episodes");
    final response = await http.get(url);
    List<WebtoonEpisodeModel> episodesInstances = [];

    if (response.statusCode == 200) {
      final episodes = jsonDecode(response.body);
      for (var episode in episodes) {
        episodesInstances.add(WebtoonEpisodeModel.fromJson(episode));
      }

      return episodesInstances;
    }
    throw Error();
  }
}
