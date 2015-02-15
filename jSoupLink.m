BeginPackage["jSoupLink`"]

ParseHTML::usage =
    "ParseHTML[address, selector, keys, useAbsoluteURL] retrieves \
attributes and content
  specified by keys and the CSS selector \"selector\" from the URL or \
local file path address.
  The last parameter useAbsoluteURL specifies whether retrieved src \
and href attributes should
  be absolute or relative. It is optional and defaults to True.";

ParseHTMLString::usage =
    "ParseHTMLString[string, selector, keys] performs the same type of \
retrieval as ParseHTML, but takes an HTML string instead of a file.";

ParseHTMLFragment::usage =
    "ParseHTMLFragment[string, selector, keys] is just like \
ParseHTMLString, but if the string isn't a complete HTML document but \
instead only a part of the body of the document then this method may \
perform better, since it will add html and body tags to make the \
document complete before it attempts to parse it.";

Begin["`Private`"]
Needs["JLink`"]
InstallJava[];
LoadJavaClass["org.jsoup.Jsoup"]

ParseHTML[address_, selector_, keys_] := Module[{data, doc},
  JavaBlock[
  data = Import[address, "Text"];
  If[data == $Failed, Return[$Failed]];
  doc = Jsoup`parse[data, address];
  parse[doc, selector, keys]
  ]
]

ParseHTMLString[string_, selector_, keys_] := Module[{doc},
  JavaBlock[
  doc = Jsoup`parse@string;
  parse[doc, selector, keys, False]
  ]
]

ParseHTMLFragment[string_, selector_, keys_] := Module[{doc},
  JavaBlock[
  doc = Jsoup`parseBodyFragment[string];
  parse[doc, selector, keys, False]
  ]
]

parse[doc_, selector_, keys_, useAbsoluteURL_: True] :=
    Module[{data, elements, res, newKeys},
      JavaBlock[
      elements = doc@select@selector;
      elements = Table[elements@get[i - 1], {i, elements@size[]}];

      res = Outer[Switch[#2,
        "html", #@html[],
        "ownText", #@ownText[],
        "text", #@text[],
        "tagName", #@tagName[],
        "src", If[useAbsoluteURL, #@absUrl@"src", #@attr@"src"],
        "href", If[useAbsoluteURL, #@absUrl@"href", #@attr@"href"],
        _, #@attr@#2
      ] &,
        elements,
        If[Head@keys === String, {keys}, keys]
      ];

      If[Head@keys === String, First /@ res, res]
      ]
    ]

End[]

EndPackage[]