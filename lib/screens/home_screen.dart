import 'package:flutter/material.dart';
import 'package:webtoon_naver/models/webtoon_model.dart';
import 'package:webtoon_naver/services/api_service.dart';
import 'package:webtoon_naver/widgets/webtoon_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final Future<List<WebtoonModel>> webtoons = ApiService().getTodaysToons();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "오늘의 웹툰",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        foregroundColor: Colors.green,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder(
        future: webtoons,
        // snapshot: Future의 상태를 알려준다.
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // ListView.separated는 자동으로 유저가 보고 있는 item만 로드한다.
            return Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Expanded(
                  child: makeWebtoonList(
                    snapshot,
                  ),
                )
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  ListView makeWebtoonList(AsyncSnapshot<List<WebtoonModel>> snapshot) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: snapshot.data!.length,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      // itemBuilder: 현재 사용자가 보고 있는 부분에 대한 데이터만 보여준다.
      itemBuilder: (context, index) {
        var webtoon = snapshot.data![index];
        return Webtoon(
            title: webtoon.title, thumb: webtoon.thumb, id: webtoon.id);
      },
      // separatorBuilderf: 각 item 사이에 들어갈 위젯을 지정
      separatorBuilder: (context, index) => const SizedBox(
        width: 24,
      ),
    );
  }
}
