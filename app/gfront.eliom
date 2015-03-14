(* Front page *)
open Boa_core

let view () =
  let open View in 
  Boa_skeleton.return
    "A sample title"
    [
      Boa_gui.modal
        ~classes:["center-content"]
        [
          p [pcdata "blablablablabla"]; 
          Boa_gui.button
            ~classes:["button_standard"]
            (Boa_ui.Link.service (Service.self) () "A button")
        ]
         
    ]

let service =
  Register.page
    ~path:[]
    view
