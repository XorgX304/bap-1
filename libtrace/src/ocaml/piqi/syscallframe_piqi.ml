module rec Syscallframe_piqi :
             sig
               type uint64 = int64
               
               type thread_id = Syscallframe_piqi.uint64
               
               type address = Syscallframe_piqi.uint64
               
               type bit_length = int
               
               type taint_id = Syscallframe_piqi.uint64
               
               type exception_number = Syscallframe_piqi.uint64
               
               type syscall_frame = Syscall_frame.t
               
               type argument_list = Syscallframe_piqi.argument list
               
               type argument = int64
               
             end = Syscallframe_piqi
and
  Syscall_frame :
    sig
      type t =
        { mutable address : Syscallframe_piqi.address;
          mutable thread_id : Syscallframe_piqi.thread_id;
          mutable number : Syscallframe_piqi.uint64;
          mutable argument_list : Syscallframe_piqi.argument_list
        }
      
    end = Syscall_frame
  
include Syscallframe_piqi
  
let rec parse_uint64 x = Piqirun.int64_of_varint x
and packed_parse_uint64 x = Piqirun.int64_of_packed_varint x
and parse_int x = Piqirun.int_of_zigzag_varint x
and packed_parse_int x = Piqirun.int_of_packed_zigzag_varint x
and parse_int64 x = Piqirun.int64_of_zigzag_varint x
and packed_parse_int64 x = Piqirun.int64_of_packed_zigzag_varint x
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
and parse_syscall_frame x =
  let x = Piqirun.parse_record x in
  let (_address, x) = Piqirun.parse_required_field 1 parse_address x in
  let (_thread_id, x) = Piqirun.parse_required_field 2 parse_thread_id x in
  let (_number, x) = Piqirun.parse_required_field 3 parse_uint64 x in
  let (_argument_list, x) =
    Piqirun.parse_required_field 4 parse_argument_list x
  in
    (Piqirun.check_unparsed_fields x;
     {
       Syscall_frame.address = _address;
       Syscall_frame.thread_id = _thread_id;
       Syscall_frame.number = _number;
       Syscall_frame.argument_list = _argument_list;
     })
and parse_argument_list x = Piqirun.parse_list parse_argument x
and parse_argument x = parse_int64 x
and packed_parse_argument x = packed_parse_int64 x
  
let rec gen__uint64 code x = Piqirun.int64_to_varint code x
and packed_gen__uint64 x = Piqirun.int64_to_packed_varint x
and gen__int code x = Piqirun.int_to_zigzag_varint code x
and packed_gen__int x = Piqirun.int_to_packed_zigzag_varint x
and gen__int64 code x = Piqirun.int64_to_zigzag_varint code x
and packed_gen__int64 x = Piqirun.int64_to_packed_zigzag_varint x
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
and gen__syscall_frame code x =
  let _address =
    Piqirun.gen_required_field 1 gen__address x.Syscall_frame.address in
  let _thread_id =
    Piqirun.gen_required_field 2 gen__thread_id x.Syscall_frame.thread_id in
  let _number =
    Piqirun.gen_required_field 3 gen__uint64 x.Syscall_frame.number in
  let _argument_list =
    Piqirun.gen_required_field 4 gen__argument_list
      x.Syscall_frame.argument_list
  in
    Piqirun.gen_record code [ _address; _thread_id; _number; _argument_list ]
and gen__argument_list code x = Piqirun.gen_list gen__argument code x
and gen__argument code x = gen__int64 code x
and packed_gen__argument x = packed_gen__int64 x
  
let gen_uint64 x = gen__uint64 (-1) x
  
let gen_int x = gen__int (-1) x
  
let gen_int64 x = gen__int64 (-1) x
  
let gen_thread_id x = gen__thread_id (-1) x
  
let gen_address x = gen__address (-1) x
  
let gen_bit_length x = gen__bit_length (-1) x
  
let gen_taint_id x = gen__taint_id (-1) x
  
let gen_exception_number x = gen__exception_number (-1) x
  
let gen_syscall_frame x = gen__syscall_frame (-1) x
  
let gen_argument_list x = gen__argument_list (-1) x
  
let gen_argument x = gen__argument (-1) x
  
let piqi =
  [ "\226\202\2304\012syscallframe\160\148\209H\129\248\174h\234\134\149\130\004&\130\153\170d!\218\164\238\191\004\tthread-id\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004$\130\153\170d\031\218\164\238\191\004\007address\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004$\130\153\170d\031\218\164\238\191\004\nbit-length\210\171\158\194\006\t\218\164\238\191\004\003int\234\134\149\130\004%\130\153\170d \218\164\238\191\004\btaint-id\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004-\130\153\170d(\218\164\238\191\004\016exception-number\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004\189\001\138\233\142\251\014\182\001\210\203\242$\031\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\r\218\164\238\191\004\007address\210\203\242$!\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\015\218\164\238\191\004\tthread-id\210\203\242$*\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\006number\210\171\158\194\006\012\218\164\238\191\004\006uint64\210\203\242$%\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\019\218\164\238\191\004\rargument-list\218\164\238\191\004\rsyscall-frame\234\134\149\130\004-\242\197\227\236\003'\218\164\238\191\004\rargument-list\210\171\158\194\006\014\218\164\238\191\004\bargument\234\134\149\130\004$\130\153\170d\031\218\164\238\191\004\bargument\210\171\158\194\006\011\218\164\238\191\004\005int64" ]
  

