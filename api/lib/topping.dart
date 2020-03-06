abstract class Topping {
  const Topping();

  String get name;
}

class ShrimpTopping extends Topping {
  const ShrimpTopping();

  String get name => "Shrimp";
}

class VegtableTopping extends Topping {
  const VegtableTopping();

  String get name => "Vegtable";
}

class CheeseTopping extends Topping {
  const CheeseTopping();

  String get name => "Cheese";
}

class PepporoniTopping extends Topping {
  const PepporoniTopping();

  String get name => "Pepporoni";
}

class AnchovyTopping extends Topping {
  const AnchovyTopping();

  String get name => "Anchovy";
}

class PineappleTopping extends Topping {
  const PineappleTopping();

  String get name => "Pineapple";
}

class MushroomTopping extends Topping {
  const MushroomTopping();

  String get name => "Mushroom";
}

class JalapenoTopping extends Topping {
  const JalapenoTopping();

  String get name => "Jalapeno";
}

class PlainTopping extends Topping {
  const PlainTopping();

  String get name => "Plain";
}
