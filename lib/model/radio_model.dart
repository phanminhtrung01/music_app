class RadioModel {
  late bool isSelected;
  late String nameString;

  RadioModel({
    this.isSelected = false,
    this.nameString = "",
  });

  @override
  String toString() {
    // TODO: implement toString
    return "RadioModel{isSelected: $isSelected;nameString: $nameString}";
  }
}
