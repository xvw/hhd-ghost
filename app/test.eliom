open Eliom_lib
open Eliom_parameter
open Boa_core
open Coord


       
module Timeline =
  struct
let view pseudo =
  let open View
  in Db.User.get_id_by_pseudo pseudo 
     >>= fun pseudo -> (print_endline "pseudo ok");  Timeline.get_closest pseudo {lat = 0.001; long = 0.001} 0.01
     >>= function
     | None -> Boa_skeleton.Mapbox.return "test_closest" [pcdata  "pas d'anecdotes"]
     | Some a ->
	let content = [pcdata  ("anecdote_id : "^Db.Timeline.(string_of_int a.anecdote_id))]
	in Boa_skeleton.Mapbox.return "test_closest" content

let service =
  Register.get
    ~path:["test_closest"]
    ~params:(suffix (string "pseudo"))
    view 

  end
