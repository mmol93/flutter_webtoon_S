import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webtoon_naver/models/webtoon_detail_model.dart';
import 'package:webtoon_naver/models/webtoon_episode_model.dart';
import 'package:webtoon_naver/services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences pref;
  final String prefsLikedWebToon = "liked_webtoon";
  bool thisWebtoonIsLiked = false;

  Future initPrefs() async {
    pref = await SharedPreferences.getInstance();
    final likedToons = pref.getStringList(prefsLikedWebToon);
    if (likedToons != null) {
      if (likedToons.contains(widget.id)) {
        setState(() {
          thisWebtoonIsLiked = true;
        });
      }
    } else {
      pref.setStringList(prefsLikedWebToon, []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService().getToonById(widget.id);
    episodes = ApiService().getLatestEpisodesById(widget.id);
    initPrefs();
  }

  onButtonTap(String episodeId) {
    final url = Uri.parse(
        "https://comic.naver.com/webtoon/detail?titleId=${widget.id}&no=$episodeId");
    launchUrl(url);
  }

  onHeartTap() async {
    final likedToons = pref.getStringList(prefsLikedWebToon);
    if (likedToons != null) {
      if (thisWebtoonIsLiked) {
        likedToons.remove(widget.id);
        setState(() {
          thisWebtoonIsLiked = false;
        });
      } else {
        likedToons.add(widget.id);
        setState(() {
          thisWebtoonIsLiked = true;
        });
      }
      await pref.setStringList(prefsLikedWebToon, likedToons);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              onHeartTap();
            },
            icon: Icon(
              thisWebtoonIsLiked
                  ? Icons.favorite
                  : Icons.favorite_border_outlined,
            ),
          )
        ],
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        foregroundColor: Colors.green,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 48,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: widget.id,
                child: Container(
                  width: 200,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          offset: const Offset(8, 8),
                          color: Colors.black.withOpacity(0.5),
                        )
                      ]),
                  child: Image.network(
                    widget.thumb,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: FutureBuilder(
              future: webtoon,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data!.about,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text("${snapshot.data!.genre} / ${snapshot.data!.age}"),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                }
                return const Text("...");
              }),
            ),
          ),
          const SizedBox(),
          Expanded(
            child: FutureBuilder(
              future: episodes,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 50, right: 50, bottom: 20),
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemBuilder: ((context, index) {
                        var episodeTitle = snapshot.data![index].title;
                        var eposodeId = snapshot.data![index].id;
                        return GestureDetector(
                          onTap: () => onButtonTap(eposodeId),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  offset: const Offset(4, 4),
                                  color: Colors.black.withOpacity(0.1),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      episodeTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      separatorBuilder: ((context, index) => const SizedBox(
                            height: 8,
                          )),
                      itemCount: snapshot.data!.length,
                    ),
                  );
                } else {
                  return Container();
                }
              }),
            ),
          )
        ],
      ),
    );
  }
}
