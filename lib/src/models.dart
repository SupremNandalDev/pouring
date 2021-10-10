
class BottleObject {
  List<FillObject> fillObjects = [];
  late int index;
  BottleObject({required this.index});

  bool get isCompletelyFilled {
    if(fillObjects.isEmpty) {
      return true;
    }
    if(fillObjects.length!=4) {
      return false;
    }
    FillObject lastObj = fillObjects.first;
    for(FillObject obj in fillObjects){
      if(obj.color!=lastObj.color) {
        return false;
      }
      lastObj = obj;
    }
    return true;
  }
}

class FillObject {
  late int color;
  late int id;
  FillObject({required this.color, required this.id});
  @override
  String toString() {
    return this.color.toString();
  }
}