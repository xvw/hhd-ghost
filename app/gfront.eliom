(* Front page *)
open Boa_core
open Eliom_parameter
       
let home_service =
  Define.page
    ~path:[]
    ()

let map_service =
  Define.post
    ~fallback:home_service
    ~params:(float "lat"
             ** float "long")
    ()
                              
       
let home_view () =
  let open Eliom_content.Html5.D in
  let form (lat, lon) =
    let lat_in = float_input ~input_type:`Text ~name:lat ()
    and lon_in = float_input ~input_type:`Text ~name:lon () in
    let _ = {unit{Boa_geolocation.push_coords %lat_in %lon_in}}
    in [ lat_in; lon_in;
         (string_input
            ~a:[a_class ["button-standard"]]
            ~input_type:`Submit
            ()
         )
       ]
  in
  let get_f = post_form ~service:map_service form () in 
  Boa_skeleton.return
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
            let map = Boa_mapbox.get "examples.map-i86nkdio" "map" in
            Boa_mapbox.targetOn map %lat %long 9.0
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
  Service.register
    ~service:map_service
    (fun () -> map_view)
    
