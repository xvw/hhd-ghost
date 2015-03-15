open Eliom_content
open Boa_core

let front_service =
  Define.page
    ~path:[]
    ()

let main_service =
  Define.page
    ~path:["home"]
    ()

let sonar_service =
  Define.page
    ~path:["sonar"]
    ()


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
                   Service.self
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
               in ()
               (* let layer = mapbox ## featureLayer () in *)
               (* layer ## loadURL(Js.string "Arthur/list.geojson"); *)
               (* layer ## addTo (map) *)
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
