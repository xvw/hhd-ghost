type t = {
    long : float;
    lat : float;
  }

let distance c1 c2 =
  Pervasives.(sqrt( (c2.lat -. c1.lat) ** 2. +. (c2.long -. c1.long) ** 2.))

let square current_coord range = 
  ((current_coord.lat +. range), (current_coord.lat -. range), (current_coord.long +. range), (current_coord.long -. range))
