open Eliom_lib
open Eliom_parameter
open Eliom_content
open Html5
open Boa_core



let get_closest user_id current_coord range =
  let open Db.Timeline in
  let predicate a = (Coord.distance current_coord a.c) < range
  and p (max,distance) a =
    let new_distance = Coord.distance current_coord a.c
    in if new_distance < distance
       then (a,new_distance)
       else (max,distance)
  in Db.Timeline.get_timeline user_id
     >|= List.filter predicate
     >|= function
       | [] -> None
       | x::xs -> Some (fst (List.fold_left p (x, Coord.distance current_coord x.c) xs))
       
       
let get_first_closest user_id current_coord range =
  let predicate a = Db.Timeline.(Coord.distance current_coord a.c) < range
  in Db.Timeline.get_timeline user_id >|=
       let rec aux = function
	 | [] -> None
	 | x::xs when predicate x-> Some x
	 | x::xs -> aux xs
       in aux 
