import 'package:flutter/material.dart';
import 'package:webtoon_naver/screens/detail_screen.dart';

class Webtoon extends StatelessWidget {
  final String title, thumb, id;

  const Webtoon({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionsBuilder:
                // secondaryAnimation: 화면 전화시 사용되는 보조 애니메이션효과
                // child: 화면이 전환되는 동안 표시할 위젯을 의미(즉, 전환 이후 표시될 위젯 정보를 의미)
                (context, animation, secondaryAnimation, child) {
              // Offset에서 x값 1은 오른쪽 끝 y값 1은 아래쪽 끝을 의미한다.
              // 애니메이션이 시작할 포인트 위치를 의미한다.
              var begin = const Offset(0, 1.0);
              var end = Offset.zero;
              // Curves.ease: 애니메이션이 부드럽게 동작하도록 명령
              var curve = Curves.ease;
              // 애니메이션의 시작과 끝을 담당한다.
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(
                CurveTween(
                  curve: curve,
                ),
              );
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetailScreen(title: title, thumb: thumb, id: id),
            fullscreenDialog: true,
          ),
        );
      },
      child: Column(
        children: [
          // CardView 처럼 보이게 하기 위해 Container를 사용
          Hero(
            tag: id,
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
                thumb,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
