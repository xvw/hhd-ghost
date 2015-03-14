open Eliom_content
open Html5.D

module type Skeleton =
  sig

    val css_files : string list list
    val js_files : string list list
    val other_header : Html5_types.head_content_fun Html5.elt list
  end

    
module Make (F : Skeleton) =
  struct 

    let raw title content =
      Eliom_tools.F.html
        ~title:title
        ~css:F.css_files
        ~js:F.js_files
        ~other_head:([
          meta
            ~a:[
              a_name "viewport";
              a_content "width = device-width"
            ] ()
        ]@F.other_header)
        (Html5.F.body content)
        
    let return title content =
      raw title content
      |> Lwt.return
                      
  end

module Base : Skeleton =
  struct

    let js_files = []
    let css_files =
      [
        ["css"; "knacss.css"];
        ["css"; "constrictor.css"];
        ["css"; "boa.css"];
        ["css"; "ghost.css"];
      ]
    let other_header = []
  end

include Make(Base)

module MBBase : Skeleton =
  struct

    let css_files = Base.css_files  
    let js_files = []
    let other_header =
      [
        css_link
          ~uri:(
            Raw.uri_of_string
              "https://api.tiles.mapbox.com/mapbox.js/v2.1.5/mapbox.css"
          ) ();
        js_script
          ~uri:(
            Raw.uri_of_string
              "https://api.tiles.mapbox.com/mapbox.js/v2.1.5/mapbox.js"
          ) ();
        
      ]
  end

module Mapbox = Make(MBBase)
