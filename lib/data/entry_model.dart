
class Entry{
  int timeStamp;
  int value;
  String label;
  double certainty;
  Entry({this.timeStamp, this.value, this.label, this.certainty});

  Map<String,dynamic> toMap(){
    return {
      // 'id':id,
      'timeStamp':timeStamp,
      'value':value,
      'label':label,
      'certainty':certainty,
    };
  }
}