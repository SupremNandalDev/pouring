import 'dart:math';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pouring/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int _systemDefault = 1;
const int _darkMode = 2;
const int _lightMode = 3;

class MainProvider extends ChangeNotifier{

  ThemeMode? _themeMode;
  ThemeMode get themeMode => _themeMode ?? ThemeMode.dark;

  IconData get iconForTheme {
    if(this.themeMode == ThemeMode.dark)
      return Icons.light_mode_rounded;
    if(this.themeMode == ThemeMode.light)
      return Icons.dark_mode_rounded;
    return Icons.light_mode_rounded;
  }

  Color getBottleColor() {
    if(this.themeMode==ThemeMode.dark) return Colors.white;
    return Colors.black;
  }

  Future init() async{
    _themeMode = await _getThemeMode();
    notifyListeners();
  }

  Future updateThemeMode() async{
    if(this._themeMode==ThemeMode.light)
      this._themeMode = ThemeMode.dark;
    else
      this._themeMode = ThemeMode.light;
    await _setThemeType(_themeMode!);
    notifyListeners();
  }

  MainProvider.init(){
    this._initializeSoundClips();
  }

  int get numOfBottlesToBeEmpty {
    if(this.currentLevel<10) return 2;
    if(this.currentLevel<100) return 3;
    return 2;
  }

  int get numOfBottles {
    if(this.currentLevel<10) return 5;
    if(this.currentLevel<20) return 6;
    if(this.currentLevel<30) return 7;
    if(this.currentLevel<60) return 8;
    if(this.currentLevel<100) return 9;
    return 10;
  }

  bool levelCompleted = false;

  Future _initializeSoundClips() async{
    this._audioMove = await _pool.load(await rootBundle.load('assets/raw/move_in.wav'));
    this._audioCantMove = await _pool.load(await rootBundle.load('assets/raw/cant_move.wav'));
    this._audioActive = await _pool.load(await rootBundle.load('assets/raw/activate.wav'));
  }

  Soundpool _pool = Soundpool.fromOptions(options: SoundpoolOptions(
      maxStreams: 5,
      streamType: StreamType.music
  ));

  int? _audioMove;
  int? _audioCantMove;
  int? _audioActive;

  @override
  void notifyListeners() {
    super.notifyListeners();
    checkIfAlreadyFinished();
  }

  Future _playMoved() async{
    if(this._audioMove==null){
      this._audioMove = await _pool.load(await rootBundle.load('assets/raw/move_in.wav'));
    }
    await this._pool.play(this._audioMove!);
  }


  Future _playCantMove()async{
    if(this._audioCantMove==null){
      this._audioCantMove = await _pool.load(await rootBundle.load('assets/raw/cant_move.wav'));
    }
    await this._pool.play(this._audioCantMove!);
  }
  Future _playActivate()async{
    if(this._audioActive==null){
      this._audioActive = await _pool.load(await rootBundle.load('assets/raw/activate.wav'));
    }
    await this._pool.play(this._audioActive!);
  }

  final Random _random = Random();
  int activeBottle = -1;
  int currentLevel = 0;

  onBottleTap(BottleObject bottle) {
    if(bottle.isCompletelyFilled && bottle.fillObjects.isNotEmpty) {
      this._playCantMove();
      return;
    }
    if(activeBottle==bottle.index){
      activeBottle = -1;
      notifyListeners();
      return;
    }
    if(activeBottle==-1){
      if(bottle.fillObjects.isEmpty){
        this._playCantMove();
        return;
      }
      activeBottle = bottle.index;
      this._playActivate();
      notifyListeners();
      return;
    }
    if(bottle.fillObjects.length==4){
      this._playCantMove();
      return;
    }

    List<FillObject> tempList = [
      ...bottles[activeBottle].fillObjects
    ];

    List<FillObject> objectsToBeMoved = getListOfMovableObjects(tempList);

    if(bottle.fillObjects.isEmpty){
      for(FillObject obj in objectsToBeMoved){
        bottles[activeBottle].fillObjects.removeAt(0);
        bottles[bottle.index].fillObjects.insert(0, obj);
      }
      activeBottle = -1;
      this._playMoved();
      notifyListeners();
      return;
    }

    FillObject targetObject = bottle.fillObjects.first;
    if(objectsToBeMoved.first.color!=targetObject.color){
      this._playCantMove();
      return;
    }

    int spaceInTargetBottle = 4-bottle.fillObjects.length;
    if(spaceInTargetBottle>=objectsToBeMoved.length){
      for(FillObject obj in objectsToBeMoved){
        bottles[activeBottle].fillObjects.removeAt(0);
        bottles[bottle.index].fillObjects.insert(0, obj);
      }
      activeBottle = -1;
      this._playMoved();
      notifyListeners();
      return;
    }
    for(int i = 0; i < spaceInTargetBottle; i ++){
      bottles[activeBottle].fillObjects.removeAt(0);
      bottles[bottle.index].fillObjects.insert(0, objectsToBeMoved[i]);
      activeBottle = -1;
    }
    this._playMoved();
    notifyListeners();
  }

  List<BottleObject> bottles = [];

  List<int> _mColors = [
    0xff1ABC9C,
    0xff2ECC71,
    0xff3498DB,
    0xffEA4C88,
    0xff9B59B6,
    0xffF1C40F,
    0xffE74C3C,
    0xffBDC3C7,
    0xffAE7C5B,
    0xffFFCCBC];

  Future initLevel({Duration? withDelay}) async{
    if(withDelay!=null)
      await Future.delayed(withDelay);



    activeBottle = -1;
    bottles = List.generate(this.numOfBottles, (index) => BottleObject(index: index));
    currentLevel = await getCurrentLevel();
    int numOfUniqueColors = this.numOfBottles-this.numOfBottlesToBeEmpty;
    int numOfFills = numOfUniqueColors*4;
    _mColors.shuffle(this._random);
    List<FillObject> fills = List.generate(numOfFills, (index) => FillObject(
        id: index, color: _mColors[getIndexForIndex(index)]
    ));
    fills.shuffle(_random);
    for(int i = 0; i < numOfUniqueColors; i++){
      bottles[i].fillObjects = [...fills.sublist(i*4,(i*4)+4)];
    }
    this.bottles.shuffle();
    for(int i = 0; i<this.bottles.length; i++){
      this.bottles[i].index = i;
    }
    notifyListeners();
  }

  getIndexForIndex(int index) {
    if(index<4){
      return 0;
    }
    return index~/4;
  }

  List<FillObject> getListOfMovableObjects(List<FillObject> tempList) {
    List<FillObject> objectsToBeMoved = [];
    FillObject lastObject = tempList.first;
    for(int i = 0; i < tempList.length; i++){
      if(lastObject.color!=tempList[i].color){
        return objectsToBeMoved;
      }
      if(lastObject.color==tempList[i].color){
        objectsToBeMoved.add(tempList[i]);
      }
      lastObject = tempList[i];
    }
    return objectsToBeMoved;
  }

  void checkIfAlreadyFinished() async{
    for(BottleObject object in bottles){
      if(!object.isCompletelyFilled){
        return;
      }
    }
    setNextLevel();
    currentLevel = await getCurrentLevel();
    initLevel();
  }

  void restoreLastSteps() {
    bottles.removeLast();
    notifyListeners();
  }
}

Future<ThemeMode> _getThemeMode() async {
  int mode = await _getThemeType();
  if(mode==_darkMode) {
    return ThemeMode.dark;
  }
  if(mode==_lightMode) {
    return ThemeMode.light;
  }
  return ThemeMode.system;
}

Future _setThemeType(ThemeMode mode) async{
  int type = _systemDefault;
  if(mode==ThemeMode.light) {
    type = _lightMode;
  } else if(mode==ThemeMode.dark) {
    type = _darkMode;
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("selected_theme", type);
}

Future _getThemeType() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt("selected_theme") ?? _lightMode;
}

Future<void> setNextLevel() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('current_level', (await getCurrentLevel()) + 1);
}

Future<int> getCurrentLevel() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt("current_level") ?? 1;
}