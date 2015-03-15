{shared{

open Eliom_content.Html5.D    
open Eliom_parameter

open Yojson
open Yojson.Basic
open Yojson.Basic.Util    

open Boa_core
       
module Config = struct
  
  let url = "https://api.foursquare.com"       
  let client_id =
    "AM1SBROOU5WWWSY0TNPXU14IS0D5NMN5MTPXNXLHFROHTSIO"
  let client_secret =
    "X3OCTCZKH54JHEAFZMXT4MAWZZBDA005LRSLEEDJQELRNJ3J"
  let version = "20130815"
		  
end


let request = 
  Eliom_service.Http.external_service
    ~prefix:Config.url
    ~path:[ "v2"
	  ; "venues"
	  ; "search"
	  ]
    ~get_params:(string "client_id"
		 ** string "client_secret"
		 ** string "v"
		 ** string "ll"
		 ** string "query")
    ()

let create_url lt lg query =
  let open Config in
  let lt = string_of_float lt
  and lg = string_of_float lg in
  let ll = (lt ^ "," ^ lg) in
  Eliom_content.Html5.D.make_string_uri
    ~service:request
    (client_id,
    (client_secret,
    (version,
    (ll,query))))

let requestPH = 
  Eliom_service.Http.external_service
    ~prefix:""
    ~path:["4sq"]
    ~get_params:(float "lat"
		 ** float "lng"
		 ** string "query")
    ()

let create_urlPH lat lng query =
  Eliom_content.Html5.D.make_string_uri
    ~service:requestPH
    (lat,
    (lng,query))
   }}	 

                  
let front_service =
  Define.page
    ~path:[]
    ()

    
let main_service =
  Define.page
    ~path:["home"]
    ()

let api =
  Define.page
    ~path:["api"]
    ()

let _ =
  Eliom_registration.String.register
    ~service:api
    (fun () () ->
     let marker = [
       Boa_mapbox.Parameter.marker
         ~title:"Joseph Pollet"
         ~descr:"Je suis le createur de la Redoute, Salut, savais-tu que la Redoute tient son nom de la rue ou se situait la premiere usine ? "
         (3.168813, 50.696978)]
     in
     (Boa_mapbox.Parameter.to_string marker, "application/json")
     |> Lwt.return
    )
  
let get_JSON lt lg query =
  create_url lt lg query
  |> Boa_http.get_frame_content
              
let json_content lt lg query =
  let r = get_JSON lt lg query in
  from_string @@ Lwt_main.run r

let make_marker json = 
  let name =
    json
    |> member "name"
    |> to_string
  in	 
  let categories =
    json
    |> member "categories"
    |> to_list
    |> List.hd
  in	 
  let subtitle =
    categories
    |> member "name"
    |> to_string
  in  
  let loc =
    let loc' = member "location" json in
    ( member "lng" loc' |> to_float
    , member "lat" loc' |> to_float)
  in      
  Boa_mapbox.Parameter.marker
    ~title:name
    ~descr:subtitle
    loc
    
let make_markers json_content =
  let xs =
    json_content |> member "response" |> member "venues" |> to_list
  in
  List.map make_marker xs	   

let foursquare =
  Define.get
    ~path:["4sq"]
    ~params:(float  "lat" **
	       float  "lng" **
		 string "query"
		)
    ()
    
let _ =
  Eliom_registration.String.register
    ~service:foursquare
    (fun (lat ,(lng ,query)) () ->
     let cnt = json_content lat lng query
	       |> make_markers
	       |> Boa_mapbox.Parameter.to_string
     in
     Lwt.return (cnt, "application/json"))

let home_service =
  Define.page
    ~path:["pokedex"]
    ()

    
let sonar_service =
  Define.page
    ~path:["sonar"]
    ()


let map_service =
  Define.post
    ~fallback:home_service
    ~params:(float "lat"
             ** float "long"
	     ** string "query")
    ()

let from_bib_view () =
  let open Eliom_content.Html5.D in
  let form (lat, (lgt, query)) =
    let lat_in = float_input ~input_type:`Hidden ~name:lat ()
    and lgt_in = float_input ~input_type:`Hidden ~name:lgt () in
    let _ = {unit{Boa_geolocation.push_coords %lat_in %lgt_in}} in
    [
      lat_in ; lgt_in ;
      string_input ~input_type:`Text ~name:query ();
      string_input ~input_type:`Submit ()
    ]
  in
  let get_f =
    post_form
      ~service:map_service
      form
      ()
  in
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
                 let coords = Js.array [|(50.696978);(3.168813)|] in
                 (map ## setView (coords, 20.0))
               in 
               let layer = mapbox ## featureLayer () in
               layer ## loadURL(Js.string "api");
               layer ## addTo (map)
              )
          }}
     in 
     
  Boa_skeleton.Mapbox.return
    "Bibli"
    [
      div ~a:[a_id "map"] [];
      div ~a:[a_class ["input-box"]]
          [
           Boa_ui.Link.service
             ~a:[]
             main_service
             ()
             "Retour";
           get_f
          ];
      
    ]
    
let map_view () (lat, (long, query)) =
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
              mapbox ## map (Js.string "map",
			     Js.string "andreaen.55f1bc1b") in
            let _ =
              let coords = Js.array [|(%lat);(%long)|] in
              (map ## setView (coords, 45.0))
            in
            let layer = mapbox ## featureLayer () in
	    let url = create_urlPH %lat %long %query in
	    layer ## loadURL(Js.string url);
            layer ## addTo (map)
           )
       }}
  in
  Boa_skeleton.Mapbox.return
    "Map sample"
    [ map_div ]
    

let _ =
  Service.register
    ~service:map_service
    map_view 
  
let _ =
  Service.register
    ~service:home_service
    (fun () () -> from_bib_view ())


let _ =
  Service.register
    ~service:main_service
    (fun () () ->
     let open View in
     Boa_skeleton.Mapbox.return
       "On the main !"
       [
         Boa_gui.modal
           ~classes:["center-content"]
           [
             img
               ~alt:"Avatar formidable"
               ~a:[a_class ["avatar"]]
               ~src:(Boa_uri.gravatar "andreaen.sd@gmail.com")
               ();
             div
               ~a:[a_class ["high"]]
               [
                 
                 Boa_ui.Link.service
                   ~a:[a_class ["button-standard"; "block"]]
                   sonar_service
                   ()
                   "Sonar"
               ];
             div
               ~a:[a_class ["low"]]
               [
                 Boa_ui.Link.service
                   ~a:[a_class ["button-standard"; "block"]]
                   home_service
                   ()
                   "Bibliothèque"
               ]
           ]
       ]
    )

    
    
let _ =
  Service.register
    ~service:front_service
    (fun () () ->
     let open View in 
     Boa_skeleton.Mapbox.return
       "Hello !"
       [
         Boa_gui.modal
           ~classes:["center-content"]
           [
             a
               ~service:main_service
               [img
                  ~a:[a_class ["logo"]]
                  ~alt:"Hello sir !"
                  ~src:(
                    make_uri
                      ~service:(Eliom_service.static_dir ())
                   ["images"; "mini.png"]
                  )
                  ()] ()
           ]
       ]
    )

    
let _ =
  Service.register
    ~service:sonar_service
    (fun () () ->
     let open Eliom_content.Html5.D in
     let d = div ~a:[a_id "map"] [] in
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
                 let coords = Js.array [|(50.696978);(3.168813)|] in
                 (map ## setView (coords, 20.0))
               in 
               let layer = mapbox ## featureLayer () in
               layer ## loadURL(Js.string "api");
               layer ## addTo (map)
              )
          }}
     in 
     Boa_skeleton.Mapbox.return
       "Sonar"
       [
         d;
         Boa_ui.Link.service
           ~a:[a_class ["button-standard"; "block"; "fluide"]]
           main_service
           ()
           "Retour";
       ]
    )

