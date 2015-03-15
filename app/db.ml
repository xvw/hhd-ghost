open Eliom_lib

let user_id_seq = <:sequence< serial "user_id_seq" >>
let ghost_id_seq = <:sequence< serial "ghost_id_seq" >>
let anecdote_id_seq = <:sequence< serial "anecdote_id_seq" >>
let catch_id_seq = <:sequence< serial "catch_id_seq" >>

		     
let table_users =
  <:table< users (
   user_id integer NOT NULL DEFAULT(nextval $user_id_seq$),
   pseudo text NOT NULL,
   email text NOT NULL,
   password text NOT NULL
   )>>

let table_ghosts =
  <:table< ghosts (
   ghost_id integer NOT NULL DEFAULT(nextval $ghost_id_seq$),
   patronymic text NOT NULL,
   image_path text NOT NULL
   ) >>

let table_anecdotes =
  <:table<  anecdotes (
   anecdote_id integer NOT NULL DEFAULT(nextval $anecdote_id_seq$),
   ghost_id integer NOT NULL,
   reported boolean NOT NULL,
   feedback_average double NOT NULL,
   n_feedback double NOT NULL,
   synopsis text NOT NULL,
   full_content text NOT NULL,
   latitude double NOT NULL,
   longitude double NOT NULL
   ) >>

let table_catch =
  <:table<  catch (
   catch_id integer NOT NULL DEFAULT(nextval $catch_id_seq$),
   anecdote_id integer NOT NULL,
   user_id integer NOT NULL,
   feedback double ,
   catch_date date NOT NULL
   )>>

module User =
  struct
    let get_id_by_pseudo pseudo =
      (Boa_db.view_one (<< {id = u.user_id} | u in $table_users$ ; u.pseudo = $string:pseudo$>>)) >|= (
	fun x -> Int32.to_int (x#!id)
      )
  end
    
module Timeline =
  struct
    (* projection du resultat de la fonction get_timeline *)
    type get_timeline_result = {
	anecdote_id : int;
	full_content : string;
	synopsis : string;
	feedback_average : float; 
	date : CalendarLib.Date.field CalendarLib.Date.date;
	ghost_name : string;
	image_path : string;
	c : Coord.t;
      }
				 
    let get_timeline user_id =
      let project_result result =
	{
	  anecdote_id = Int32.to_int (result#!anecdote_id);
    	  full_content = result#!full_content;
    	  synopsis = result#!synopsis;
    	  feedback_average = result#!feedback_average;
    	  date = result#!date;
	  ghost_name = result#!ghost_name;
	  image_path = result#!image_path;
	  c = {long = result#!longitude; lat = result#!latitude}
    	}
      in Boa_db.view (<<{anecdote_id = a.anecdote_id; full_content = a.full_content; synopsis = a.synopsis; feedback_average = a.feedback_average;a.latitude; a.longitude; date = c.catch_date; ghost_name = g.patronymic; image_path = g.image_path}
    		       | a in $table_anecdotes$;
    		       c in $table_catch$;
		       g in $table_ghosts$;
    		       a.anecdote_id = c.anecdote_id;
    		       c.user_id = $int32:(Int32.of_int user_id)$;
		       a.ghost_id = g.ghost_id
    		       >>)
    	 >|= (List.map project_result)
	 >|= (List.sort (fun x y -> CalendarLib.Date.compare (x.date) (y.date)))		     
  end
