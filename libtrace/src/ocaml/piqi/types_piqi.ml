module rec Types_piqi :
             sig
               type uint64 = int64
               
               type thread_id = Types_piqi.uint64
               
               type address = Types_piqi.uint64
               
               type bit_length = int
               
               type taint_id = Types_piqi.uint64
               
               type exception_number = Types_piqi.uint64
               
             end = Types_piqi
  
include Types_piqi
  
let rec parse_uint64 x = Piqirun.int64_of_varint x
and packed_parse_uint64 x = Piqirun.int64_of_packed_varint x
and parse_int x = Piqirun.int_of_zigzag_varint x
and packed_parse_int x = Piqirun.int_of_packed_zigzag_varint x
and parse_thread_id x = parse_uint64 x
and packed_parse_thread_id x = packed_parse_uint64 x
and parse_address x = parse_uint64 x
and packed_parse_address x = packed_parse_uint64 x
and parse_bit_length x = parse_int x
and packed_parse_bit_length x = packed_parse_int x
and parse_taint_id x = parse_uint64 x
and packed_parse_taint_id x = packed_parse_uint64 x
and parse_exception_number x = parse_uint64 x
and packed_parse_exception_number x = packed_parse_uint64 x
  
let rec gen__uint64 code x = Piqirun.int64_to_varint code x
and packed_gen__uint64 x = Piqirun.int64_to_packed_varint x
and gen__int code x = Piqirun.int_to_zigzag_varint code x
and packed_gen__int x = Piqirun.int_to_packed_zigzag_varint x
and gen__thread_id code x = gen__uint64 code x
and packed_gen__thread_id x = packed_gen__uint64 x
and gen__address code x = gen__uint64 code x
and packed_gen__address x = packed_gen__uint64 x
and gen__bit_length code x = gen__int code x
and packed_gen__bit_length x = packed_gen__int x
and gen__taint_id code x = gen__uint64 code x
and packed_gen__taint_id x = packed_gen__uint64 x
and gen__exception_number code x = gen__uint64 code x
and packed_gen__exception_number x = packed_gen__uint64 x
  
let gen_uint64 x = gen__uint64 (-1) x
  
let gen_int x = gen__int (-1) x
  
let gen_thread_id x = gen__thread_id (-1) x
  
let gen_address x = gen__address (-1) x
  
let gen_bit_length x = gen__bit_length (-1) x
  
let gen_taint_id x = gen__taint_id (-1) x
  
let gen_exception_number x = gen__exception_number (-1) x
  
let piqi =
  [ "\226\202\2304\005types\160\148\209H\129\248\174h\234\134\149\130\004&\130\153\170d!\218\164\238\191\004\tthread-id\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004$\130\153\170d\031\218\164\238\191\004\007address\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004$\130\153\170d\031\218\164\238\191\004\nbit-length\210\171\158\194\006\t\218\164\238\191\004\003int\234\134\149\130\004%\130\153\170d \218\164\238\191\004\btaint-id\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004-\130\153\170d(\218\164\238\191\004\016exception-number\210\171\158\194\006\012\218\164\238\191\004\006uint64" ]
  

