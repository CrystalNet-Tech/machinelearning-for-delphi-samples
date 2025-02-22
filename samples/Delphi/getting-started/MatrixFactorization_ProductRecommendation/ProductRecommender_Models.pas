unit ProductRecommender_Models;

interface
uses MLAttributes, MLCore, System.Generics.Collections;

type

  TProductEntry = class(TMLEntity)
  public
    [KeyType(262111)]
    ProductID: Cardinal;

    [KeyType(262111)]
    CoPurchaseProductID: Cardinal;
  end;

 TCopurchase_prediction = class(TMLEntity)
  public
    Score: Single;
 end;


implementation


end.
