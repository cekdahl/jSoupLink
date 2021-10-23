(* Mathematica Package                     *)

(* :Title: jsoupLink                       *)
(* :Context: jsoupLink`                    *)
(* :Author: Calle Ekdahl                   *)
(* :Date: 2018-11-03                       *)

(* :Package Version: 1.0                   *)
(* :Mathematica Version: 11.3.0.0          *)
(* :Copyright: (c) 2015-2018 Calle Ekdahl  *)
(* :Keywords:                              *)
(* :Discussion:                            *)

BeginPackage["jsoupLink`"]
(* Exported symbols added here with SymbolName::usage *)

Begin["`Private`"] (* Begin Private Context *)

Needs["JLink`"]
InstallJava[];
AddToClassPath[FileNameJoin[{DirectoryName[$InputFileName], "Java/jsoup-1.9.2.jar"}]];
LoadJavaClass["org.jsoup.Jsoup"];

ImportExport`RegisterImport["HTMLDOM", jsoupLink`DownloadDOM];
ImportExport`RegisterExport["HTMLDOM", jsoupLink`ExportDOM];

DownloadDOM[filename_String, opts___] := ParseDOM[Import[filename, "Text", opts]]
DownloadDOM[$Failed, _String] := $Failed

ParseDOM[html_String, baseUri_String:""] := Module[{doc, root},
  doc = JavaBlock[Jsoup`parse[html, baseUri]];
  root = First[doc@children[]@toArray[]];
  Global`HTMLElement[root]
]

ExportDOM[filename_, data_, opts___] := Export[filename, data["OuterHTML"], "Text",opts]

icon = Import[FileNameJoin[{DirectoryName[$InputFileName], "assets/documenticon.png"}]];

(* http://mathematica.stackexchange.com/questions/77658/how-to-create-a-dynamic-expanding-displayforms-styled-like-the-ones-in-v10/79891#79891 *)
MakeBoxes[obj_Global`HTMLElement, fmt_] ^:= Module[{el = First[obj], shown, hidden, icon = Show[icon, ImageSize -> 70]},
      shown = {
        {BoxForm`MakeSummaryItem[{"Tag: ", el@tagName[]}, fmt], SpanFromLeft},
        {BoxForm`MakeSummaryItem[{"Children: ", Length@el@children[]@toArray[]}, fmt], SpanFromLeft},
        {BoxForm`MakeSummaryItem[{"Has text: ", el@hasText[]}, fmt], SpanFromLeft}
      };
      hidden = {
        {BoxForm`MakeSummaryItem[{"ID: ", el@id[]}, fmt], SpanFromLeft},
        {BoxForm`MakeSummaryItem[{"Classes: ", Row[el@classNames[]@toArray[], ", "]}, fmt], SpanFromLeft},
        {BoxForm`MakeSummaryItem[{"Block level: ", el@isBlock[]}, fmt], SpanFromLeft}
      };
      BoxForm`ArrangeSummaryBox[Global`HTMLElement, obj, icon, shown, hidden, fmt, "Interpretable" -> True]
    ];

(* https://chat.stackexchange.com/transcript/message/47430225#47430225 *)
Global`HTMLElement::reserved = "The attribute \"``\" can't be set using Set (=) because the name collides with a jsoupLink property.";
SetAttributes[myMutationHandler, HoldAllComplete];
myMutationHandler[Set[node_[attr_], val_]] := If[
  MemberQ[node["Properties"], attr],
  Message[Global`HTMLElement::reserved, attr]; node,
  node["Attribute", attr, val]
]
myMutationHandler[___] := Language`MutationFallthrough;
Language`SetMutationHandler[Global`HTMLElement, myMutationHandler]

Global`HTMLElement[el_]["TagName"] := el@tagName[]
Global`HTMLElement[el_]["TagName", tag_] := el@tagName[tag]
Global`HTMLElement[el_]["Root"] := Global`HTMLElement[First[el@ownerDocument[]@children[]@toArray[]]]
Global`HTMLElement[el_]["Parent"] := If[el@tagName[] != "html", Global`HTMLElement[el@parent[]], Global`HTMLElement[el]]
Global`HTMLElement[el_]["Children"] := Global`HTMLElement /@ el@children[]@toArray[]
Global`HTMLElement[el_]["Siblings"] := Global`HTMLElement /@ el@siblingElements[]@toArray[]
Global`HTMLElement[el_]["Select", selector_String] := Global`HTMLElement /@ el@select[selector]@toArray[]
Global`HTMLElement[el_]["AllElements"] := Global`HTMLElement /@ el@getAllElements[]@toArray[]
Global`HTMLElement[el_]["Value"] := el@val[]
Global`HTMLElement[el_]["InnerHTML"] := el@html[]
Global`HTMLElement[el_]["InnerHTML", newHTML_String] := Global`HTMLElement[el@html[newHTML]]
Global`HTMLElement[el_]["OuterHTML"] := el@outerHtml[]
Global`HTMLElement[el_]["OwnText"] := el@ownText[]
Global`HTMLElement[el_]["AllText"] := el@text[]
Global`HTMLElement[el_]["AllText", txt_] := Global`HTMLElement[el@text[txt]]
Global`HTMLElement[el_]["ID"] := el@id[]
Global`HTMLElement[el_]["ClassNames"] := el@classNames[]@toArray[]
Global`HTMLElement[el_]["HasAttribute", attribute_String] := el@hasAttr[attribute]
Global`HTMLElement[el_]["Attribute", attribute_String] := el@attr[attribute]
Global`HTMLElement[el_]["Attribute", key_String, value_String] := Global`HTMLElement[el@attr[key, value]]
Global`HTMLElement[el_]["Attribute", assoc_Association] := (KeyValueMap[el@attr[#,#2] &, assoc]; Global`HTMLElement[el])
Global`HTMLElement[el_]["Attributes"] := Association @@ (#@getKey[] -> #@getValue[] & /@ el@attributes[]@asList[]@toArray[])
Global`HTMLElement[el_]["RemoveAttribute", attribute_String] := Global`HTMLElement[el@removeAttr[attribute]]
Global`HTMLElement[el_]["IsBlock"] := el@isBlock[]
Global`HTMLElement[el_]["HasText"] := el@hasText[]
Global`HTMLElement[el_]["BaseURI"] := el@baseUri[]
Global`HTMLElement[el_]["BaseURI", uri_String] := el@setBaseUri[uri]
Global`HTMLElement[el_]["HasClass", class_String] := el@hasClass[class]
Global`HTMLElement[el_]["AddClass", class_String] := Global`HTMLElement[el@addClass[class]]
Global`HTMLElement[el_]["RemoveClass", class_String] := Global`HTMLElement[el@removeClass[class]]
Global`HTMLElement[el_]["ToggleClass", class_String] := Global`HTMLElement[el@toggleClass[class]]
Global`HTMLElement[el_]["After", html_String] := Global`HTMLElement[el@after[html]]
Global`HTMLElement[el_]["Before", html_String] := Global`HTMLElement[el@before[html]]
Global`HTMLElement[el_]["After", Global`HTMLElement[child_]] := Global`HTMLElement[el@after[child]]
Global`HTMLElement[el_]["Before", Global`HTMLElement[child_]] := Global`HTMLElement[el@before[child]]
Global`HTMLElement[el_]["Append", html_String] := Global`HTMLElement[el@append[html]]
Global`HTMLElement[el_]["Prepend", html_String] := Global`HTMLElement[el@prepend[html]]
Global`HTMLElement[el_]["Append", Global`HTMLElement[child_]] := Global`HTMLElement[el@appendChild[child]]
Global`HTMLElement[el_]["Prepend", Global`HTMLElement[child_]] := Global`HTMLElement[el@prependChild[child]]
Global`HTMLElement[el_]["ReplaceWith", Global`HTMLElement[replacement_]] := Global`HTMLElement[el@replaceWith[replacement]]
Global`HTMLElement[el_]["Remove"] := (el@remove[]; Null)
Global`HTMLElement[el_]["Wrap", html_] := Global`HTMLElement[el@wrap[html]]
Global`HTMLElement[el_]["Unwrap", html_] := With[{p=el@parent[]}, el@unwrap[]; Global`HTMLElement[p]]
Global`HTMLElement[el_]["Clean"] := Global`HTMLElement[el@html[Jsoup`clean[el@html[]]]]
Global`HTMLElement[el_]["DeepCopy"] := Global`HTMLElement[JavaBlock[el@clone[]]]
Global`HTMLElement[el_]["DOMTree"] := CreateDialog[tree[el]]

properties = {"TagName", "Root", "Parent", "Children", "Siblings",
  "Select", "AllElements", "Value", "InnerHTML", "OuterHTML",
  "OwnText", "AllText", "ID", "ClassNames", "HasAttribute",
  "Attribute", "Attributes", "RemoveAttribute", "IsBlock", "HasText",
  "BaseURI", "HasClass", "AddClass", "RemoveClass", "ToggleClass",
  "After", "Before", "Append", "Prepend", "ReplaceWith", "Remove",
  "Wrap", "Unwrap", "Clean", "DeepCopy", "DOMTree"};

Global`HTMLElement[el_]["Properties"] := properties;

hasPropertyQ[prop_] := MemberQ[properties, prop]
hasAttributeQ[node_, attr_] := MemberQ[Keys[node["Attributes"]], attr]

HTMLElement::argx = "Property `1` called with the wrong number of arguments."
HTMLElement::noproperty = "The property `1` does not exist."

Global`HTMLElement[el_][prop_?hasPropertyQ, ___] := (Message[HTMLElement::argx, prop]; $Failed)
Global`HTMLElement[el_][prop_, __] := (Message[HTMLElement::noproperty, prop]; $Failed)
Global`HTMLElement[el_][attr_?(Not[hasPropertyQ[#]]&)] := If[
  hasAttributeQ[Global`HTMLElement[el], attr],
  Global`HTMLElement[el]["Attribute", attr],
  Message[HTMLElement::noproperty, attr]; $Failed
]

(* http://mathematica.stackexchange.com/questions/59768/how-to-call-a-java-method-that-takes-a-boolean-not-boolean
This may not work on all systems. *)
Global`HTMLElement[el_]["Attribute", key_String, value:(True | False)] := Global`HTMLElement[el@attr[key, value]]

Global`HTMLElement[el_][prop_?Not@*hasPropertyQ] := Global`HTMLElement[el]["Attribute", prop]

ElementProperty[node_Global`HTMLElement, property__] := node[property]
ElementProperty[node_Global`HTMLElement][property__] := node[property]

(* DOM Tree *)
colors = <|
    "background" -> RGBColor[{1, 1, 1}],
    "tag" -> RGBColor[{117, 5, 126}/255 // N],
    "attributes" -> RGBColor[{137, 73, 0}/255 // N],
    "arguments" -> RGBColor[{46, 42, 171}/255 // N],
    "glue" -> RGBColor[{163, 148, 165}/255 // N],
    "doctype" -> RGBColor[{192, 192, 192}/255 // N],
    "comment" -> RGBColor[{68, 111, 44}/255 // N],
    "url" -> RGBColor[{47, 82, 203}/255 // N],
    "text" -> RGBColor[{54, 60, 68}/255 // N],
    "highlight" -> RGBColor[{236, 241, 252}/255 // N],
    "selected" -> <|
        "background" -> RGBColor[{79, 118, 216}/255 // N],
        "tag" -> RGBColor[{1, 1, 1}],
        "attributes" -> RGBColor[{200, 201, 203}/255 // N],
        "arguments" -> RGBColor[{1, 1, 1}],
        "glue" -> RGBColor[{157, 160, 167}/255 // N],
        "doctype" -> RGBColor[{1, 1, 1}],
        "comment" -> RGBColor[{1, 1, 1}],
        "url" -> RGBColor[{1, 1, 1}],
        "text" -> RGBColor[{1, 1, 1}]
        |>
    |>;

c::invalidColor = "The color specification `1` is not recognized.";
Options[c] = {"Selected" -> False};
c[s_String, type_String, OptionsPattern[]] := If[
  StringMatchQ[type, "tag" | "attributes" | "arguments" | "glue" | "doctype" | "comment" | "url" | "text"],
  If[OptionValue["Selected"],
    ToString[Style[s, colors["selected", type]], StandardForm],
    ToString[Style[s, colors[type]], StandardForm]
  ],
  Message[c::invalidColor, type]; ""
]
cs[s_String, type_String] := c[s, type, "Selected" -> True]

c[attributes_Association, c_: c] := StringJoin[KeyValueMap[StringJoin[
      " ",
      c[#, "attributes"],
      c["=\"", "glue"],
      If[# == "href" || # == "src",
        ToString[MouseAppearance[Hyperlink[c[#2, "url"], #2, ActiveStyle -> Underlined], "LinkHand"], StandardForm],
        c[#2, "arguments"]
      ],
      c["\"", "glue"]
    ] &, attributes]]
cs[attributes_Association] := c[attributes, cs]

elementDescription[el_, c_: c] /; InstanceOf[el, "org.jsoup.nodes.Element"] := If[
  el@childNodeSize[] > 0,
  StringJoin[
    c["<", "glue"],
    c[el@tagName[], "tag"],
    c[elementAttributes[el]],
    c[">\[Ellipsis]</", "glue"],
    c[el@tagName[], "tag"],
    c[">", "glue"]
  ],
  StringJoin[
    c["<", "glue"],
    c[el@tagName[], "tag"],
    c[elementAttributes[el]],
    c["/>", "glue"]
  ]
]

elementDescription[el_, ___] /; InstanceOf[el, "org.jsoup.nodes.TextNode"] := If[StringMatchQ[el@text[], Whitespace], Nothing, el@text[]]
elementDescription[el_, ___] /; InstanceOf[el, "org.jsoup.nodes.DataNode"] := el@getWholeData[]

elementOpen[el_, c_: c] := StringJoin[
  c["<", "glue"],
  c[el@tagName[], "tag"],
  c[elementAttributes[el]],
  c[">", "glue"]
]

elementClose[el_, c_: c] := StringJoin[
  c["</", "glue"],
  c[el@tagName[], "tag"],
  c[">", "glue"]
]

elementAttributes[el_] := Module[{attrs},
  attrs = <|#@getKey[] -> #@getValue[] & /@ el@attributes[]@asList[]@toArray[]|>;
  If[KeyExistsQ[attrs, "href"] && el@baseUri[] != "", attrs["href"] = el@attr["abs:href"]];
  If[KeyExistsQ[attrs, "src"] && el@baseUri[] != "", attrs["src"] = el@attr["abs:src"]];
  attrs
]

elementChildren[el_] := el@childNodes[]@toArray[]

attachEventHandler[element_, root_, ID_] := Item[
  EventHandler[element, {
    {"MouseClicked", 1} :> If[
      root["selected"] === ID,
      root["selected"] = Null,
      root["selected"] = ID
    ]
  }, PassEventsDown -> True],
  Alignment -> Left,
  If[root["selected"] === ID,
    Background -> colors["selected", "background"],
    ## &[]
  ]
] /; InstanceOf[ID, "org.jsoup.nodes.Element"]

attachEventHandler[el_, root_, ID_] /; InstanceOf[ID, "org.jsoup.nodes.TextNode"] := Item[el, Alignment -> Left]
attachEventHandler[Nothing[], root_, ID_] /; InstanceOf[ID, "org.jsoup.nodes.TextNode"] := Nothing
attachEventHandler[el_, root_, ID_] /; InstanceOf[ID, "org.jsoup.nodes.DataNode"] := Item[el, Alignment -> Left]

SetAttributes[CustomPaneSelector, HoldRest]
CustomPaneSelector[x_, true_, false_] := If[x, true, false]

SetAttributes[CustomOpenerView, HoldFirst]
CustomOpenerView[{heading_, content_, prolog_, epilog_}, root_, ID_, state_] := DynamicModule[{x = state},
  Dynamic@CustomPaneSelector[x,
    Grid[{
      {Opener[Dynamic[x, (root[ID] = x = #) &]], attachEventHandler[prolog, root, ID]},
      {"", Item[content, Alignment -> Left]},
      {"", attachEventHandler[epilog, root, ID]}
    }],
    Grid[{
      {Opener[Dynamic[x, (root[ID] = x = #) &]], attachEventHandler[heading, root, ID]}
    }]
  ]
]

renderElement[el_, root_, ID_, state_] := If[
  Length@elementChildren[el] > 0,
  CustomOpenerView[{
    If[root["selected"] === ID, elementDescription[el, cs], elementDescription[el]],
    Column[renderElement[#, root, #, root@#] & /@ el@childNodes[]@toArray[]],
    If[root["selected"] === ID, elementOpen[el, cs], elementOpen[el]],
    If[root["selected"] === ID, elementClose[el, cs], elementClose[el]]
  }, root, ID, state],
  attachEventHandler[If[root["selected"] === ID, elementDescription[el, cs], elementDescription[el]], root, ID]
]

Options[tree] = {
  "Width" -> 1400,
  "Height" -> 480,
  "FontSize" -> 12
}
tree[el_, OptionsPattern[]] := DynamicModule[{root},
  root[_] := False;
  root["selected"] := Null;
  Panel[Column[{
    Dynamic@Pane[Row[{
      Button["Copy node", CopyToClipboard[Global`HTMLElement[root["selected"]]], Enabled -> (root["selected"] =!= Null)],
      Button["Copy CSS selector", CopyToClipboard[root["selected"]@cssSelector[]], Enabled -> (root["selected"] =!= Null)]
    }]],
    Pane[Deploy@renderElement[el, root, el, False],
      Scrollbars -> True,
      BaseStyle -> {Background -> White, FontSize -> OptionValue["FontSize"]},
      ImageSize -> {OptionValue["Width"], OptionValue["Height"]},
      FrameMargins -> 20
    ]
  }]]
]

Options[popup] = {
  "WindowWidth" -> 1420,
  "WindowHeight" -> 560
  "Width" -> 1400,
  "Height" -> 480,
  "FontSize" -> 12
}
popup[el_, opts: OptionsPattern[]] := CreateDocument[tree[el, opts],
  "CellInsertionPointCell" -> Cell[],
  ShowCellBracket -> False,
  WindowElements -> {},
  WindowFrame -> "Generic",
  WindowSize -> {OptionValue["WindowWidth"], OptionValue["WindowHeight"]},
  WindowTitle -> None,
  WindowToolbars -> {}
]

End[] (* End Private Context *)

EndPackage[]
