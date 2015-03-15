(* Front page *)
open Boa_core
open Eliom_parameter
       
let home_service =
  Define.page
    ~path:[]
    ()

let api_service =
  Define.page
    ~path:["Arthur"; "list.geojson"]
    ()

let map_service =
  Define.post
    ~fallback:home_service
    ~params:(float "lat"
             ** float "long")
    ()

let connect_service =
  Define.post
    ~fallback:home_service
    ~params:(string "nick" ** string "pass")
    ()


let home_view () =
  let open Eliom_content.Html5.D in
  let form (nick, pass) =
    [
      string_input ~input_type:`Text ~name:nick ();
      string_input ~input_type:`Password ~name:pass (); 
    ]
  in 
  Boa_skeleton.Mapbox.return
    "Hello"
    [
      
    ]
       
let map_init_view () =
  let open Eliom_content.Html5.D in
  let form (lat, lon) =
    let lat_in = float_input ~input_type:`Hidden ~name:lat ()
    and lon_in = float_input ~input_type:`Hidden ~name:lon () in
    let _ = {unit{Boa_geolocation.push_coords %lat_in %lon_in}}
    in [ lat_in; lon_in;
         (string_input
            ~a:[a_class ["button-standard"]; a_value "Délivrer"]
            ~input_type:`Submit
            ()
         )
       ]
  in
  let get_f = post_form ~service:map_service form () in 
  Boa_skeleton.Mapbox.return
    "A sample title"
    [
      Boa_gui.modal
        ~classes:["center-content"]
        [div ~a:[a_class ["input-box"]] [get_f]]
         
    ]

let map_view (lat, long) =
  let open Eliom_content.Html5.D in
  let map_div = div ~a:[a_id "map"] [] in
  let _ =
    {unit{
         Eliom_client.onload
           (fun () ->
            let mL = Js.Unsafe.variable "L" in
            let mapbox = mL ## mapbox in 
            let _ = mapbox ## accessToken <- Boa_mapbox.token in
            let map =
              mapbox ## map (Js.string "map", Js.string"andreaen.55f1bc1b") in
            let _ =
              let coords = Js.array [|(%lat);(%long)|] in
              (map ## setView (coords, 45.0))
            in
            let layer = mapbox ## featureLayer () in
            layer ## loadURL(Js.string "Arthur/list.geojson");
            layer ## addTo (map)
           )
       }}
  in 
  Boa_skeleton.Mapbox.return
    "Map sample"
    [ map_div ]

let _ =
  Service.register
    ~service:home_service
    (fun () -> home_view)

let _ =
  Eliom_registration.String.register
    ~service:api_service
    (fun () () ->
     let marker = [
       Boa_mapbox.Parameter.marker
         ~title:"Arthur"
         ~descr:"Un programmeur C"
         (38.1089, 13.3545)]
     in
     (Boa_mapbox.Parameter.to_string marker, "application/json")
     |> Lwt.return 
    )
    
let _ =
  Service.register
    ~service:map_service
    (fun () -> map_view)
    
