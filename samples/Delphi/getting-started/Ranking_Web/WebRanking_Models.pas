unit WebRanking_Models;

interface
uses MLCore, MLAttributes;

type

  TSearchResultData = class(TMLEntity)
  public
    [ColumnName('Label'), LoadColumn(0)]
    &Label: UInt32; // { get; set; }

    [ColumnName('GroupId'), LoadColumn(1)]
    GroupId: UInt32; // { get; set; }

    [ColumnName('CoveredQueryTermNumberAnchor'), LoadColumn(2)]
    CoveredQueryTermNumberAnchor: Single; // { get; set; }


    [ColumnName('CoveredQueryTermNumberTitle'), LoadColumn(3)]
    CoveredQueryTermNumberTitle: Single; // { get; set; }


    [ColumnName('CoveredQueryTermNumberUrl'), LoadColumn(4)]
    CoveredQueryTermNumberUrl: Single; // { get; set; }


    [ColumnName('CoveredQueryTermNumberWholeDocument'), LoadColumn(5)]
    CoveredQueryTermNumberWholeDocument: Single; // { get; set; }


    [ColumnName('CoveredQueryTermNumberBody'), LoadColumn(6)]
    CoveredQueryTermNumberBody: Single; // { get; set; }


    [ColumnName('CoveredQueryTermRatioAnchor'), LoadColumn(7)]
    CoveredQueryTermRatioAnchor: Single; // { get; set; }


    [ColumnName('CoveredQueryTermRatioTitle'), LoadColumn(8)]
    CoveredQueryTermRatioTitle: Single; // { get; set; }


    [ColumnName('CoveredQueryTermRatioUrl'), LoadColumn(9)]
    CoveredQueryTermRatioUrl: Single; // { get; set; }


    [ColumnName('CoveredQueryTermRatioWholeDocument'), LoadColumn(10)]
    CoveredQueryTermRatioWholeDocument: Single; // { get; set; }


    [ColumnName('CoveredQueryTermRatioBody'), LoadColumn(11)]
    CoveredQueryTermRatioBody: Single; // { get; set; }


    [ColumnName('StreamLengthAnchor'), LoadColumn(12)]
    StreamLengthAnchor: Single; // { get; set; }


    [ColumnName('StreamLengthTitle'), LoadColumn(13)]
    StreamLengthTitle: Single; // { get; set; }


    [ColumnName('StreamLengthUrl'), LoadColumn(14)]
    StreamLengthUrl: Single; // { get; set; }


    [ColumnName('StreamLengthWholeDocument'), LoadColumn(15)]
    StreamLengthWholeDocument: Single; // { get; set; }


    [ColumnName('StreamLengthBody'), LoadColumn(16)]
    StreamLengthBody: Single; // { get; set; }


    [ColumnName('IdfAnchor'), LoadColumn(17)]
    IdfAnchor: Single; // { get; set; }


    [ColumnName('IdfTitle'), LoadColumn(18)]
    IdfTitle: Single; // { get; set; }


    [ColumnName('IdfUrl'), LoadColumn(19)]
    IdfUrl: Single; // { get; set; }


    [ColumnName('IdfWholeDocument'), LoadColumn(20)]
    IdfWholeDocument: Single; // { get; set; }


    [ColumnName('IdfBody'), LoadColumn(21)]
    IdfBody: Single; // { get; set; }


    [ColumnName('SumTfAnchor'), LoadColumn(22)]
    SumTfAnchor: Single; // { get; set; }


    [ColumnName('SumTfTitle'), LoadColumn(23)]
    SumTfTitle: Single; // { get; set; }


    [ColumnName('SumTfUrl'), LoadColumn(24)]
    SumTfUrl: Single; // { get; set; }


    [ColumnName('SumTfWholeDocument'), LoadColumn(25)]
    SumTfWholeDocument: Single; // { get; set; }


    [ColumnName('SumTfBody'), LoadColumn(26)]
    SumTfBody: Single; // { get; set; }


    [ColumnName('MinTfAnchor'), LoadColumn(27)]
    MinTfAnchor: Single; // { get; set; }


    [ColumnName('MinTfTitle'), LoadColumn(28)]
    MinTfTitle: Single; // { get; set; }


    [ColumnName('MinTfUrl'), LoadColumn(29)]
    MinTfUrl: Single; // { get; set; }


    [ColumnName('MinTfWholeDocument'), LoadColumn(30)]
    MinTfWholeDocument: Single; // { get; set; }


    [ColumnName('MinTfBody'), LoadColumn(31)]
    MinTfBody: Single; // { get; set; }


    [ColumnName('MaxTfAnchor'), LoadColumn(32)]
    MaxTfAnchor: Single; // { get; set; }


    [ColumnName('MaxTfTitle'), LoadColumn(33)]
    MaxTfTitle: Single; // { get; set; }


    [ColumnName('MaxTfUrl'), LoadColumn(34)]
    MaxTfUrl: Single; // { get; set; }


    [ColumnName('MaxTfWholeDocument'), LoadColumn(35)]
    MaxTfWholeDocument: Single; // { get; set; }


    [ColumnName('MaxTfBody'), LoadColumn(36)]
    MaxTfBody: Single; // { get; set; }


    [ColumnName('MeanTfAnchor'), LoadColumn(37)]
    MeanTfAnchor: Single; // { get; set; }


    [ColumnName('MeanTfTitle'), LoadColumn(38)]
    MeanTfTitle: Single; // { get; set; }


    [ColumnName('MeanTfUrl'), LoadColumn(39)]
    MeanTfUrl: Single; // { get; set; }


    [ColumnName('MeanTfWholeDocument'), LoadColumn(40)]
    MeanTfWholeDocument: Single; // { get; set; }


    [ColumnName('MeanTfBody'), LoadColumn(41)]
    MeanTfBody: Single; // { get; set; }


    [ColumnName('VarianceTfAnchor'), LoadColumn(42)]
    VarianceTfAnchor: Single; // { get; set; }


    [ColumnName('VarianceTfTitle'), LoadColumn(43)]
    VarianceTfTitle: Single; // { get; set; }


    [ColumnName('VarianceTfUrl'), LoadColumn(44)]
    VarianceTfUrl: Single; // { get; set; }


    [ColumnName('VarianceTfWholeDocument'), LoadColumn(45)]
    VarianceTfWholeDocument: Single; // { get; set; }


    [ColumnName('VarianceTfBody'), LoadColumn(46)]
    VarianceTfBody: Single; // { get; set; }


    [ColumnName('SumStreamLengthNormalizedTfAnchor'), LoadColumn(47)]
    SumStreamLengthNormalizedTfAnchor: Single; // { get; set; }


    [ColumnName('SumStreamLengthNormalizedTfTitle'), LoadColumn(48)]
    SumStreamLengthNormalizedTfTitle: Single; // { get; set; }


    [ColumnName('SumStreamLengthNormalizedTfUrl'), LoadColumn(49)]
    SumStreamLengthNormalizedTfUrl: Single; // { get; set; }


    [ColumnName('SumStreamLengthNormalizedTfWholeDocument'), LoadColumn(50)]
    SumStreamLengthNormalizedTfWholeDocument: Single; // { get; set; }


    [ColumnName('SumStreamLengthNormalizedTfBody'), LoadColumn(51)]
    SumStreamLengthNormalizedTfBody: Single; // { get; set; }


    [ColumnName('MinStreamLengthNormalizedTfAnchor'), LoadColumn(52)]
    MinStreamLengthNormalizedTfAnchor: Single; // { get; set; }


    [ColumnName('MinStreamLengthNormalizedTfTitle'), LoadColumn(53)]
    MinStreamLengthNormalizedTfTitle: Single; // { get; set; }


    [ColumnName('MinStreamLengthNormalizedTfUrl'), LoadColumn(54)]
    MinStreamLengthNormalizedTfUrl: Single; // { get; set; }


    [ColumnName('MinStreamLengthNormalizedTfWholeDocument'), LoadColumn(55)]
    MinStreamLengthNormalizedTfWholeDocument: Single; // { get; set; }


    [ColumnName('MinStreamLengthNormalizedTfBody'), LoadColumn(56)]
    MinStreamLengthNormalizedTfBody: Single; // { get; set; }


    [ColumnName('MaxStreamLengthNormalizedTfAnchor'), LoadColumn(57)]
    MaxStreamLengthNormalizedTfAnchor: Single; // { get; set; }


    [ColumnName('MaxStreamLengthNormalizedTfTitle'), LoadColumn(58)]
    MaxStreamLengthNormalizedTfTitle: Single; // { get; set; }


    [ColumnName('MaxStreamLengthNormalizedTfUrl'), LoadColumn(59)]
    MaxStreamLengthNormalizedTfUrl: Single; // { get; set; }


    [ColumnName('MaxStreamLengthNormalizedTfWholeDocument'), LoadColumn(60)]
    MaxStreamLengthNormalizedTfWholeDocument: Single; // { get; set; }


    [ColumnName('MaxStreamLengthNormalizedTfBody'), LoadColumn(61)]
    MaxStreamLengthNormalizedTfBody: Single; // { get; set; }


    [ColumnName('MeanStreamLengthNormalizedTfAnchor'), LoadColumn(62)]
    MeanStreamLengthNormalizedTfAnchor: Single; // { get; set; }


    [ColumnName('MeanStreamLengthNormalizedTfTitle'), LoadColumn(63)]
    MeanStreamLengthNormalizedTfTitle: Single; // { get; set; }


    [ColumnName('MeanStreamLengthNormalizedTfUrl'), LoadColumn(64)]
    MeanStreamLengthNormalizedTfUrl: Single; // { get; set; }


    [ColumnName('MeanStreamLengthNormalizedTfWholeDocument'), LoadColumn(65)]
    MeanStreamLengthNormalizedTfWholeDocument: Single; // { get; set; }


    [ColumnName('MeanStreamLengthNormalizedTfBody'), LoadColumn(66)]
    MeanStreamLengthNormalizedTfBody: Single; // { get; set; }


    [ColumnName('VarianceStreamLengthNormalizedTfAnchor'), LoadColumn(67)]
    VarianceStreamLengthNormalizedTfAnchor: Single; // { get; set; }


    [ColumnName('VarianceStreamLengthNormalizedTfTitle'), LoadColumn(68)]
    VarianceStreamLengthNormalizedTfTitle: Single; // { get; set; }


    [ColumnName('VarianceStreamLengthNormalizedTfUrl'), LoadColumn(69)]
    VarianceStreamLengthNormalizedTfUrl: Single; // { get; set; }


    [ColumnName('VarianceStreamLengthNormalizedTfWholeDocument'), LoadColumn(70)]
    VarianceStreamLengthNormalizedTfWholeDocument: Single; // { get; set; }


    [ColumnName('VarianceStreamLengthNormalizedTfBody'), LoadColumn(71)]
    VarianceStreamLengthNormalizedTfBody: Single; // { get; set; }


    [ColumnName('SumTfidfAnchor'), LoadColumn(72)]
    SumTfidfAnchor: Single; // { get; set; }


    [ColumnName('SumTfidfTitle'), LoadColumn(73)]
    SumTfidfTitle: Single; // { get; set; }


    [ColumnName('SumTfidfUrl'), LoadColumn(74)]
    SumTfidfUrl: Single; // { get; set; }


    [ColumnName('SumTfidfWholeDocument'), LoadColumn(75)]
    SumTfidfWholeDocument: Single; // { get; set; }


    [ColumnName('SumTfidfBody'), LoadColumn(76)]
    SumTfidfBody: Single; // { get; set; }


    [ColumnName('MinTfidfAnchor'), LoadColumn(77)]
    MinTfidfAnchor: Single; // { get; set; }


    [ColumnName('MinTfidfTitle'), LoadColumn(78)]
    MinTfidfTitle: Single; // { get; set; }


    [ColumnName('MinTfidfUrl'), LoadColumn(79)]
    MinTfidfUrl: Single; // { get; set; }


    [ColumnName('MinTfidfWholeDocument'), LoadColumn(80)]
    MinTfidfWholeDocument: Single; // { get; set; }


    [ColumnName('MinTfidfBody'), LoadColumn(81)]
    MinTfidfBody: Single; // { get; set; }


    [ColumnName('MaxTfidfAnchor'), LoadColumn(82)]
    MaxTfidfAnchor: Single; // { get; set; }


    [ColumnName('MaxTfidfTitle'), LoadColumn(83)]
    MaxTfidfTitle: Single; // { get; set; }


    [ColumnName('MaxTfidfUrl'), LoadColumn(84)]
    MaxTfidfUrl: Single; // { get; set; }


    [ColumnName('MaxTfidfWholeDocument'), LoadColumn(85)]
    MaxTfidfWholeDocument: Single; // { get; set; }


    [ColumnName('MaxTfidfBody'), LoadColumn(86)]
    MaxTfidfBody: Single; // { get; set; }


    [ColumnName('MeanTfidfAnchor'), LoadColumn(87)]
    MeanTfidfAnchor: Single; // { get; set; }


    [ColumnName('MeanTfidfTitle'), LoadColumn(88)]
    MeanTfidfTitle: Single; // { get; set; }


    [ColumnName('MeanTfidfUrl'), LoadColumn(89)]
    MeanTfidfUrl: Single; // { get; set; }


    [ColumnName('MeanTfidfWholeDocument'), LoadColumn(90)]
    MeanTfidfWholeDocument: Single; // { get; set; }


    [ColumnName('MeanTfidfBody'), LoadColumn(91)]
    MeanTfidfBody: Single; // { get; set; }


    [ColumnName('VarianceTfidfAnchor'), LoadColumn(92)]
    VarianceTfidfAnchor: Single; // { get; set; }


    [ColumnName('VarianceTfidfTitle'), LoadColumn(93)]
    VarianceTfidfTitle: Single; // { get; set; }


    [ColumnName('VarianceTfidfUrl'), LoadColumn(94)]
    VarianceTfidfUrl: Single; // { get; set; }


    [ColumnName('VarianceTfidfWholeDocument'), LoadColumn(95)]
    VarianceTfidfWholeDocument: Single; // { get; set; }


    [ColumnName('VarianceTfidfBody'), LoadColumn(96)]
    VarianceTfidfBody: Single; // { get; set; }


    [ColumnName('BooleanModelAnchor'), LoadColumn(97)]
    BooleanModelAnchor: Single; // { get; set; }


    [ColumnName('BooleanModelTitle'), LoadColumn(98)]
    BooleanModelTitle: Single; // { get; set; }


    [ColumnName('BooleanModelUrl'), LoadColumn(99)]
    BooleanModelUrl: Single; // { get; set; }


    [ColumnName('BooleanModelWholeDocument'), LoadColumn(100)]
    BooleanModelWholeDocument: Single; // { get; set; }


    [ColumnName('BooleanModelBody'), LoadColumn(101)]
    BooleanModelBody: Single; // { get; set; }


    [ColumnName('VectorSpaceModelAnchor'), LoadColumn(102)]
    VectorSpaceModelAnchor: Single; // { get; set; }


    [ColumnName('VectorSpaceModelTitle'), LoadColumn(103)]
    VectorSpaceModelTitle: Single; // { get; set; }


    [ColumnName('VectorSpaceModelUrl'), LoadColumn(104)]
    VectorSpaceModelUrl: Single; // { get; set; }


    [ColumnName('VectorSpaceModelWholeDocument'), LoadColumn(105)]
    VectorSpaceModelWholeDocument: Single; // { get; set; }


    [ColumnName('VectorSpaceModelBody'), LoadColumn(106)]
    VectorSpaceModelBody: Single; // { get; set; }


    [ColumnName('Bm25Anchor'), LoadColumn(107)]
    Bm25Anchor: Single; // { get; set; }


    [ColumnName('Bm25Title'), LoadColumn(108)]
    Bm25Title: Single; // { get; set; }


    [ColumnName('Bm25Url'), LoadColumn(109)]
    Bm25Url: Single; // { get; set; }


    [ColumnName('Bm25WholeDocument'), LoadColumn(110)]
    Bm25WholeDocument: Single; // { get; set; }


    [ColumnName('Bm25Body'), LoadColumn(111)]
    Bm25Body: Single; // { get; set; }


    [ColumnName('LmirAbsAnchor'), LoadColumn(112)]
    LmirAbsAnchor: Single; // { get; set; }


    [ColumnName('LmirAbsTitle'), LoadColumn(113)]
    LmirAbsTitle: Single; // { get; set; }


    [ColumnName('LmirAbsUrl'), LoadColumn(114)]
    LmirAbsUrl: Single; // { get; set; }


    [ColumnName('LmirAbsWholeDocument'), LoadColumn(115)]
    LmirAbsWholeDocument: Single; // { get; set; }


    [ColumnName('LmirAbsBody'), LoadColumn(116)]
    LmirAbsBody: Single; // { get; set; }


    [ColumnName('LmirDirAnchor'), LoadColumn(117)]
    LmirDirAnchor: Single; // { get; set; }


    [ColumnName('LmirDirTitle'), LoadColumn(118)]
    LmirDirTitle: Single; // { get; set; }


    [ColumnName('LmirDirUrl'), LoadColumn(119)]
    LmirDirUrl: Single; // { get; set; }


    [ColumnName('LmirDirWholeDocument'), LoadColumn(120)]
    LmirDirWholeDocument: Single; // { get; set; }


    [ColumnName('LmirDirBody'), LoadColumn(121)]
    LmirDirBody: Single; // { get; set; }


    [ColumnName('LmirJmAnchor'), LoadColumn(122)]
    LmirJmAnchor: Single; // { get; set; }


    [ColumnName('LmirJmTitle'), LoadColumn(123)]
    LmirJmTitle: Single; // { get; set; }


    [ColumnName('LmirJmUrl'), LoadColumn(124)]
    LmirJmUrl: Single; // { get; set; }


    [ColumnName('LmirJmWholeDocument'), LoadColumn(125)]
    LmirJmWholeDocument: Single; // { get; set; }


    [ColumnName('LmirJm'), LoadColumn(126)]
    LmirJm: Single; // { get; set; }


    [ColumnName('NumberSlashInUrl'), LoadColumn(127)]
    NumberSlashInUrl: Single; // { get; set; }


    [ColumnName('LengthUrl'), LoadColumn(128)]
    LengthUrl: Single; // { get; set; }


    [ColumnName('InlinkNumber'), LoadColumn(129)]
    InlinkNumber: Single; // { get; set; }


    [ColumnName('OutlinkNumber'), LoadColumn(130)]
    OutlinkNumber: Single; // { get; set; }


    [ColumnName('PageRank'), LoadColumn(131)]
    PageRank: Single; // { get; set; }


    [ColumnName('SiteRank'), LoadColumn(132)]
    SiteRank: Single; // { get; set; }


    [ColumnName('QualityScore'), LoadColumn(133)]
    QualityScore: Single; // { get; set; }


    [ColumnName('QualityScore2'), LoadColumn(134)]
    QualityScore2: Single; // { get; set; }


    [ColumnName('QueryUrlClickCount'), LoadColumn(135)]
    QueryUrlClickCount: Single; // { get; set; }


    [ColumnName('UrlClickCount'), LoadColumn(136)]
    UrlClickCount: Single; // { get; set; }


    [ColumnName('UrlDwellTime'), LoadColumn(137)]
    UrlDwellTime: Single; // { get; set; }
  end;

  // Representation of the prediction made by the model (e.g. ranker).
  TSearchResultPrediction = class(TMLEntity)
  public
    GroupId: UInt32; // { get; set; }
    &Label: UInt32; // { get; set; }

    // Prediction made by the model that is used to indicate the relative ranking of the candidate search results.
    Score: Single; // { get; set; }
    // Values that are influential in determining the relevance of a data instance. This is a vector that contains concatenated columns from the underlying dataset.
    Features: TArray<Single>; // { get; set; }
  end;

implementation

end.
