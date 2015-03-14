(* Mapbox API *)
{shared{
     open Eliom_content
     open Html5
     open Boa_core
     let (>>=) = Lwt.bind
     let access = "pk.eyJ1IjoiYW5kcmVhZW4i"
     let access' = "LCJhIjoiYjNPT0RtYyJ9.B1gFZrq5axjQ5hKDI0Tn1w"
     let token = access ^ access'
   }}

{client{

     let get map_id elt =
       let _ = Dom_html.window ## alert (Js.string "lEl") in
       let map_obj =
         let l = Js.Unsafe.variable "L" in
         (l ## mapbox)
       in
       let _ = Dom_html.window ## alert (Js.string "lol") in
       let _ = (map_obj ## accessToken <- token)
       in (map_obj ## map (Js.string elt, Js.string map_id))

     let targetOn map_obj x y zoom =
       let coords = Js.array [|x;y|] in
       (map_obj ## setView (coords, zoom))

     let importParameters map_obj url =
       let layer = map_obj ## featureLayer () in
       let _ = (layer ## loadUrl (Js.string "url")) in
       (layer ## addTo map_obj)

   }}

module Parameter =
  struct 

    type properties =
      { title : string
      ; description : string
      ; marker_symbol : string
      } deriving (Yojson)

    type geometry =
      { typ : string
      ; coordinates : float list
      } deriving (Yojson)

    type marker =
      { typ : string
      ; geometry : geometry
      ; properties : properties
      } deriving (Yojson)

    type geojson = (marker list) deriving (Yojson)
    type markerlist = (marker list) deriving (Yojson)

    let geometry ~lat ~lon =
      { typ = "Point"
      ; coordinates = [lat ; lon]
      }

    let properties ~title ~descr ~marker_sym =
      { title = title
      ; description = descr
      ; marker_symbol = marker_sym
      }

    let marker ?(marker_sym="") ~title ~descr ~lat ~lon =
      { typ = "Feature"
      ; geometry   = geometry ~lat ~lon
      ; properties = properties ~title ~descr ~marker_sym
      }

    let to_string v =
      Yojson.to_string<markerlist> v
      |> Str.(global_replace (regexp "typ") ("type"))
      |> Str.(global_replace (regexp "-") ("_"))

  end
    
