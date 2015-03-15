open Lwt
let ( >>= ) = Lwt.bind
exception Empty_Frame_Content
 
let get_frame_content ?(size=24096) url =
  Ocsigen_http_client.get_url url >>= fun x ->
  x.frame_content
  |> (function
       | Some s -> s
       | None -> raise Empty_Frame_Content)
  |> Ocsigen_stream.get
  |> Ocsigen_stream.string_of_stream size 
