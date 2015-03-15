open Eliom_lib
open Eliom_parameter
open Eliom_content
open Html5
open Boa_core



let get_closest user_id current_coord range =
  let predicate a = Db.Timeline.(Coord.distance current_coord a.c) < range
  in Db.Timeline.get_timeline user_id >|=
       let rec aux = function
	 | [] -> None
	 | x::xs when predicate x-> Some x
	 | x::xs -> aux xs
       in aux 
