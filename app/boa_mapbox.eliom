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

     let get () =
       let l = Js.Unsafe.variable "L" in
       let map_obj = l ## mapbox in
       let _ = map_obj ## accessToken <- token
       in map_obj

       
     let appendTo map_obj map_id elt =
       map_obj ## map (Js.string elt, Js.string map_id)

     let targetOn map_obj x y zoom =
       let coords = Js.array [|x;y|] in
       map_obj ## setView (coords, zoom)

     let importParameters map_obj url =
       let layer = map_obj ## featureLayer () in
       let _ = layer ## loadUrl (Js.string "url") in
       layer ## addTo map_obj
       
       

   }}

module Parameter =
  struct 

    type properties =
      { title : string
      ; description : string
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

    let properties ~title ~descr =
      { title = title
      ; description = descr
      }

    let marker ~title ~descr ~lat ~lon =
      { typ = "Feature"
      ; geometry   = geometry ~lat ~lon
      ; properties = properties ~title ~descr
      }

    let to_string v =
      Yojson.to_string<markerlist> v
      |> Str.(global_replace (regexp "typ") ("type"))

  end
    
