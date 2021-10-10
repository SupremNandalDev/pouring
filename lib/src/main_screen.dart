import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pouring/src/painter.dart';
import 'package:provider/provider.dart';

import 'main_provider.dart';

class MainScreenRoute extends StatelessWidget {
  const MainScreenRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MainProvider>(
        builder: (context, provider, child){
          if(provider.bottles.isEmpty){
            provider.initLevel(withDelay: Duration(milliseconds: 200));
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                  'Level:- ${provider.currentLevel}'
              ),
              actions: [
                IconButton(
                  onPressed: () => provider.updateThemeMode(),
                  icon: Icon(
                    provider.iconForTheme
                  ),
                ),
                IconButton(
                  icon: const Icon(
                      Icons.refresh_rounded
                  ),
                  onPressed: (){
                    provider.initLevel();
                  },
                ),
              ],
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: Opacity(
                    opacity: 0.3,
                    child: Lottie.asset(
                        'assets/raw/01.json',
                        frameRate: FrameRate.max,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width
                    ),
                  ),
                ),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: provider.bottles.map((bottle) {
                      return GestureDetector(
                        onTap: () => provider.onBottleTap(bottle),
                        child: Transform.translate(
                          offset: Offset(0, bottle.index==provider.activeBottle? -24.0 : 0.0),
                          child: Container(
                            height: 135,
                            width: 50,
                            margin: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(100.0)
                                )
                            ),
                            child: CustomPaint(
                              foregroundPainter: CustomContainerShapeBorder(
                                provider.getBottleColor()
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: bottle.fillObjects.map((fill) {
                                        int index = bottle.fillObjects.indexOf(fill);
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4.0
                                          ),
                                          decoration: BoxDecoration(
                                              color: Color(fill.color),
                                              borderRadius: getBorderRadiusForIndex(index, bottle.fillObjects.length)
                                          ),
                                          height: 24,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  if(bottle.isCompletelyFilled && bottle.fillObjects.isNotEmpty)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  bottom: 8.0,
                  right: 8.0,
                  left: 8.0,
                  child: Text(
                    'https://github.com/SupremNandalDev\nhttps://Suprem.dev',
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
  getBorderRadiusForIndex(int index, int max) {
    if(index==0 && max==4) {
      return const BorderRadius.vertical(top: Radius.circular(18.0));
    }
    if(index+1==max || index==3){
      return const BorderRadius.vertical(bottom: Radius.circular(8.0));
    }
    return BorderRadius.zero;
  }
}
