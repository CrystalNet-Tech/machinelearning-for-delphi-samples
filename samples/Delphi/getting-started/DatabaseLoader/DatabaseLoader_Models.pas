unit DatabaseLoader_Models;

interface
uses MLCore, MLAttributes;

type

  TClickPrediction = class(TMLEntity)
  public
    PredictedLabel: Boolean;
    Score: Single;
  end;

  TUrlClick = class(TMLEntity)
  public
    &Label: string;
    Feat01: string;
    Feat02: string;
    Feat03: string;
    Feat04: string;
    Feat05: string;
    Feat06: string;
    Feat07: string;
    Feat08: string;
    Feat09: string;
    Feat10: string;
    Feat11: string;
    Feat12: string;
    Feat13: string;
    Cat14: string;
    Cat15: string;
    Cat16: string;
    Cat17: string;
    Cat18: string;
    Cat19: string;
    Cat20: string;
    Cat21: string;
    Cat22: string;
    Cat23: string;
    Cat24: string;
    Cat25: string;
    Cat26: string;
    Cat27: string;
    Cat28: string;
    Cat29: string;
    Cat30: string;
    Cat31: string;
    Cat32: string;
    Cat33: string;
    Cat34: string;
    Cat35: string;
    Cat36: string;
    Cat37: string;
    Cat38: string;
    Cat39: string;
  end;

implementation

end.
