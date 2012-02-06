module rec Frame_piqi :
             sig
               type operand_info_specific =
                 [
                   | `mem_operand of Frame_piqi.mem_operand
                   | `reg_operand of Frame_piqi.reg_operand
                 ]
               
               type taint_info =
                 [
                   | `no_taint
                   | `taint_id of Frame_piqi.taint_id
                   | `taint_multiple
                 ]
               
               type frame =
                 [
                   | `std_frame of Frame_piqi.std_frame
                   | `syscall_frame of Frame_piqi.syscall_frame
                   | `exception_frame of Frame_piqi.exception_frame
                   | `taint_intro_frame of Frame_piqi.taint_intro_frame
                 ]
               
               type uint64 = int64
               
               type binary = string
               
               type thread_id = Frame_piqi.uint64
               
               type address = Frame_piqi.uint64
               
               type bit_length = int
               
               type taint_id = Frame_piqi.uint64
               
               type exception_number = Frame_piqi.uint64
               
               type std_frame = Std_frame.t
               
               type operand_list = Frame_piqi.operand_info list
               
               type operand_info = Operand_info.t
               
               type reg_operand = Reg_operand.t
               
               type mem_operand = Mem_operand.t
               
               type operand_usage = Operand_usage.t
               
               type syscall_frame = Syscall_frame.t
               
               type argument_list = Frame_piqi.argument list
               
               type argument = int64
               
               type exception_frame = Exception_frame.t
               
               type taint_intro_frame = Taint_intro_frame.t
               
               type taint_intro_list = Frame_piqi.taint_intro list
               
               type taint_intro = Taint_intro.t
               
             end = Frame_piqi
and
  Std_frame :
    sig
      type t =
        { mutable address : Frame_piqi.address;
          mutable thread_id : Frame_piqi.thread_id;
          mutable rawbytes : Frame_piqi.binary;
          mutable operand_list : Frame_piqi.operand_list
        }
      
    end = Std_frame
and
  Operand_info :
    sig
      type t =
        { mutable operand_info_specific : Frame_piqi.operand_info_specific;
          mutable bit_length : Frame_piqi.bit_length;
          mutable operand_usage : Frame_piqi.operand_usage;
          mutable taint_info : Frame_piqi.taint_info;
          mutable value : Frame_piqi.binary
        }
      
    end = Operand_info
and Reg_operand : sig type t = { mutable name : string }
                       end = Reg_operand
and
  Mem_operand : sig type t = { mutable address : Frame_piqi.address }
                     end =
    Mem_operand
and
  Operand_usage :
    sig
      type t =
        { mutable read : bool; mutable written : bool; mutable index : bool;
          mutable base : bool
        }
      
    end = Operand_usage
and
  Syscall_frame :
    sig
      type t =
        { mutable address : Frame_piqi.address;
          mutable thread_id : Frame_piqi.thread_id;
          mutable number : Frame_piqi.uint64;
          mutable argument_list : Frame_piqi.argument_list
        }
      
    end = Syscall_frame
and
  Exception_frame :
    sig
      type t =
        { mutable exception_number : Frame_piqi.exception_number;
          mutable thread_id : Frame_piqi.thread_id option;
          mutable from_addr : Frame_piqi.address;
          mutable to_addr : Frame_piqi.address
        }
      
    end = Exception_frame
and
  Taint_intro_frame :
    sig type t = { mutable taint_intro_list : Frame_piqi.taint_intro_list }
        
    end = Taint_intro_frame
and
  Taint_intro :
    sig
      type t =
        { mutable addr : Frame_piqi.address;
          mutable taint_id : Frame_piqi.taint_id
        }
      
    end = Taint_intro
  
include Frame_piqi
  
let rec parse_uint64 x = Piqirun.int64_of_varint x
and packed_parse_uint64 x = Piqirun.int64_of_packed_varint x
and parse_int x = Piqirun.int_of_zigzag_varint x
and packed_parse_int x = Piqirun.int_of_packed_zigzag_varint x
and parse_binary x = Piqirun.string_of_block x
and parse_string x = Piqirun.string_of_block x
and parse_bool x = Piqirun.bool_of_varint x
and packed_parse_bool x = Piqirun.bool_of_packed_varint x
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
and parse_std_frame x =
  let x = Piqirun.parse_record x in
  let (_address, x) = Piqirun.parse_required_field 1 parse_address x in
  let (_thread_id, x) = Piqirun.parse_required_field 2 parse_thread_id x in
  let (_rawbytes, x) = Piqirun.parse_required_field 3 parse_binary x in
  let (_operand_list, x) =
    Piqirun.parse_required_field 4 parse_operand_list x
  in
    (Piqirun.check_unparsed_fields x;
     {
       Std_frame.address = _address;
       Std_frame.thread_id = _thread_id;
       Std_frame.rawbytes = _rawbytes;
       Std_frame.operand_list = _operand_list;
     })
and parse_operand_list x = Piqirun.parse_list parse_operand_info x
and parse_operand_info x =
  let x = Piqirun.parse_record x in
  let (_operand_info_specific, x) =
    Piqirun.parse_required_field 1 parse_operand_info_specific x in
  let (_bit_length, x) = Piqirun.parse_required_field 2 parse_bit_length x in
  let (_operand_usage, x) =
    Piqirun.parse_required_field 3 parse_operand_usage x in
  let (_taint_info, x) = Piqirun.parse_required_field 4 parse_taint_info x in
  let (_value, x) = Piqirun.parse_required_field 5 parse_binary x
  in
    (Piqirun.check_unparsed_fields x;
     {
       Operand_info.operand_info_specific = _operand_info_specific;
       Operand_info.bit_length = _bit_length;
       Operand_info.operand_usage = _operand_usage;
       Operand_info.taint_info = _taint_info;
       Operand_info.value = _value;
     })
and parse_operand_info_specific x =
  let (code, x) = Piqirun.parse_variant x
  in
    match code with
    | 1 -> let res = parse_mem_operand x in `mem_operand res
    | 2 -> let res = parse_reg_operand x in `reg_operand res
    | _ -> Piqirun.error_variant x code
and parse_reg_operand x =
  let x = Piqirun.parse_record x in
  let (_name, x) = Piqirun.parse_required_field 1 parse_string x
  in (Piqirun.check_unparsed_fields x; { Reg_operand.name = _name; })
and parse_mem_operand x =
  let x = Piqirun.parse_record x in
  let (_address, x) = Piqirun.parse_required_field 1 parse_address x
  in (Piqirun.check_unparsed_fields x; { Mem_operand.address = _address; })
and parse_operand_usage x =
  let x = Piqirun.parse_record x in
  let (_read, x) = Piqirun.parse_required_field 1 parse_bool x in
  let (_written, x) = Piqirun.parse_required_field 2 parse_bool x in
  let (_index, x) = Piqirun.parse_required_field 3 parse_bool x in
  let (_base, x) = Piqirun.parse_required_field 4 parse_bool x
  in
    (Piqirun.check_unparsed_fields x;
     {
       Operand_usage.read = _read;
       Operand_usage.written = _written;
       Operand_usage.index = _index;
       Operand_usage.base = _base;
     })
and parse_taint_info x =
  let (code, x) = Piqirun.parse_variant x
  in
    match code with
    | 1 when x = (Piqirun.Varint 1) -> `no_taint
    | 2 -> let res = parse_taint_id x in `taint_id res
    | 3 when x = (Piqirun.Varint 1) -> `taint_multiple
    | _ -> Piqirun.error_variant x code
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
and parse_exception_frame x =
  let x = Piqirun.parse_record x in
  let (_exception_number, x) =
    Piqirun.parse_required_field 1 parse_exception_number x in
  let (_thread_id, x) = Piqirun.parse_optional_field 2 parse_thread_id x in
  let (_from_addr, x) = Piqirun.parse_required_field 3 parse_address x in
  let (_to_addr, x) = Piqirun.parse_required_field 4 parse_address x
  in
    (Piqirun.check_unparsed_fields x;
     {
       Exception_frame.exception_number = _exception_number;
       Exception_frame.thread_id = _thread_id;
       Exception_frame.from_addr = _from_addr;
       Exception_frame.to_addr = _to_addr;
     })
and parse_taint_intro_frame x =
  let x = Piqirun.parse_record x in
  let (_taint_intro_list, x) =
    Piqirun.parse_required_field 1 parse_taint_intro_list x
  in
    (Piqirun.check_unparsed_fields x;
     { Taint_intro_frame.taint_intro_list = _taint_intro_list; })
and parse_taint_intro_list x = Piqirun.parse_list parse_taint_intro x
and parse_taint_intro x =
  let x = Piqirun.parse_record x in
  let (_addr, x) = Piqirun.parse_required_field 1 parse_address x in
  let (_taint_id, x) = Piqirun.parse_required_field 2 parse_taint_id x
  in
    (Piqirun.check_unparsed_fields x;
     { Taint_intro.addr = _addr; Taint_intro.taint_id = _taint_id; })
and parse_frame x =
  let (code, x) = Piqirun.parse_variant x
  in
    match code with
    | 1 -> let res = parse_std_frame x in `std_frame res
    | 2 -> let res = parse_syscall_frame x in `syscall_frame res
    | 3 -> let res = parse_exception_frame x in `exception_frame res
    | 4 -> let res = parse_taint_intro_frame x in `taint_intro_frame res
    | _ -> Piqirun.error_variant x code
  
let rec gen__uint64 code x = Piqirun.int64_to_varint code x
and packed_gen__uint64 x = Piqirun.int64_to_packed_varint x
and gen__int code x = Piqirun.int_to_zigzag_varint code x
and packed_gen__int x = Piqirun.int_to_packed_zigzag_varint x
and gen__binary code x = Piqirun.string_to_block code x
and gen__string code x = Piqirun.string_to_block code x
and gen__bool code x = Piqirun.bool_to_varint code x
and packed_gen__bool x = Piqirun.bool_to_packed_varint x
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
and gen__std_frame code x =
  let _address =
    Piqirun.gen_required_field 1 gen__address x.Std_frame.address in
  let _thread_id =
    Piqirun.gen_required_field 2 gen__thread_id x.Std_frame.thread_id in
  let _rawbytes =
    Piqirun.gen_required_field 3 gen__binary x.Std_frame.rawbytes in
  let _operand_list =
    Piqirun.gen_required_field 4 gen__operand_list x.Std_frame.operand_list
  in
    Piqirun.gen_record code
      [ _address; _thread_id; _rawbytes; _operand_list ]
and gen__operand_list code x = Piqirun.gen_list gen__operand_info code x
and gen__operand_info code x =
  let _operand_info_specific =
    Piqirun.gen_required_field 1 gen__operand_info_specific
      x.Operand_info.operand_info_specific in
  let _bit_length =
    Piqirun.gen_required_field 2 gen__bit_length x.Operand_info.bit_length in
  let _operand_usage =
    Piqirun.gen_required_field 3 gen__operand_usage
      x.Operand_info.operand_usage in
  let _taint_info =
    Piqirun.gen_required_field 4 gen__taint_info x.Operand_info.taint_info in
  let _value = Piqirun.gen_required_field 5 gen__binary x.Operand_info.value
  in
    Piqirun.gen_record code
      [ _operand_info_specific; _bit_length; _operand_usage; _taint_info;
        _value ]
and gen__operand_info_specific code (x : Frame_piqi.operand_info_specific) =
  Piqirun.gen_record code
    [ (match x with
       | `mem_operand x -> gen__mem_operand 1 x
       | `reg_operand x -> gen__reg_operand 2 x) ]
and gen__reg_operand code x =
  let _name = Piqirun.gen_required_field 1 gen__string x.Reg_operand.name
  in Piqirun.gen_record code [ _name ]
and gen__mem_operand code x =
  let _address =
    Piqirun.gen_required_field 1 gen__address x.Mem_operand.address
  in Piqirun.gen_record code [ _address ]
and gen__operand_usage code x =
  let _read = Piqirun.gen_required_field 1 gen__bool x.Operand_usage.read in
  let _written =
    Piqirun.gen_required_field 2 gen__bool x.Operand_usage.written in
  let _index =
    Piqirun.gen_required_field 3 gen__bool x.Operand_usage.index in
  let _base = Piqirun.gen_required_field 4 gen__bool x.Operand_usage.base
  in Piqirun.gen_record code [ _read; _written; _index; _base ]
and gen__taint_info code (x : Frame_piqi.taint_info) =
  Piqirun.gen_record code
    [ (match x with
       | `no_taint -> Piqirun.gen_bool_field 1 true
       | `taint_id x -> gen__taint_id 2 x
       | `taint_multiple -> Piqirun.gen_bool_field 3 true) ]
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
and gen__exception_frame code x =
  let _exception_number =
    Piqirun.gen_required_field 1 gen__exception_number
      x.Exception_frame.exception_number in
  let _thread_id =
    Piqirun.gen_optional_field 2 gen__thread_id x.Exception_frame.thread_id in
  let _from_addr =
    Piqirun.gen_required_field 3 gen__address x.Exception_frame.from_addr in
  let _to_addr =
    Piqirun.gen_required_field 4 gen__address x.Exception_frame.to_addr
  in
    Piqirun.gen_record code
      [ _exception_number; _thread_id; _from_addr; _to_addr ]
and gen__taint_intro_frame code x =
  let _taint_intro_list =
    Piqirun.gen_required_field 1 gen__taint_intro_list
      x.Taint_intro_frame.taint_intro_list
  in Piqirun.gen_record code [ _taint_intro_list ]
and gen__taint_intro_list code x = Piqirun.gen_list gen__taint_intro code x
and gen__taint_intro code x =
  let _addr = Piqirun.gen_required_field 1 gen__address x.Taint_intro.addr in
  let _taint_id =
    Piqirun.gen_required_field 2 gen__taint_id x.Taint_intro.taint_id
  in Piqirun.gen_record code [ _addr; _taint_id ]
and gen__frame code (x : Frame_piqi.frame) =
  Piqirun.gen_record code
    [ (match x with
       | `std_frame x -> gen__std_frame 1 x
       | `syscall_frame x -> gen__syscall_frame 2 x
       | `exception_frame x -> gen__exception_frame 3 x
       | `taint_intro_frame x -> gen__taint_intro_frame 4 x) ]
  
let gen_uint64 x = gen__uint64 (-1) x
  
let gen_int x = gen__int (-1) x
  
let gen_binary x = gen__binary (-1) x
  
let gen_string x = gen__string (-1) x
  
let gen_bool x = gen__bool (-1) x
  
let gen_int64 x = gen__int64 (-1) x
  
let gen_thread_id x = gen__thread_id (-1) x
  
let gen_address x = gen__address (-1) x
  
let gen_bit_length x = gen__bit_length (-1) x
  
let gen_taint_id x = gen__taint_id (-1) x
  
let gen_exception_number x = gen__exception_number (-1) x
  
let gen_std_frame x = gen__std_frame (-1) x
  
let gen_operand_list x = gen__operand_list (-1) x
  
let gen_operand_info x = gen__operand_info (-1) x
  
let gen_operand_info_specific x = gen__operand_info_specific (-1) x
  
let gen_reg_operand x = gen__reg_operand (-1) x
  
let gen_mem_operand x = gen__mem_operand (-1) x
  
let gen_operand_usage x = gen__operand_usage (-1) x
  
let gen_taint_info x = gen__taint_info (-1) x
  
let gen_syscall_frame x = gen__syscall_frame (-1) x
  
let gen_argument_list x = gen__argument_list (-1) x
  
let gen_argument x = gen__argument (-1) x
  
let gen_exception_frame x = gen__exception_frame (-1) x
  
let gen_taint_intro_frame x = gen__taint_intro_frame (-1) x
  
let gen_taint_intro_list x = gen__taint_intro_list (-1) x
  
let gen_taint_intro x = gen__taint_intro (-1) x
  
let gen_frame x = gen__frame (-1) x
  
let piqi =
  [ "\226\202\2304\005frame\160\148\209H\129\248\174h\234\134\149\130\004&\130\153\170d!\218\164\238\191\004\tthread-id\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004$\130\153\170d\031\218\164\238\191\004\007address\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004$\130\153\170d\031\218\164\238\191\004\nbit-length\210\171\158\194\006\t\218\164\238\191\004\003int\234\134\149\130\004%\130\153\170d \218\164\238\191\004\btaint-id\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004-\130\153\170d(\218\164\238\191\004\016exception-number\210\171\158\194\006\012\218\164\238\191\004\006uint64\234\134\149\130\004\186\001\138\233\142\251\014\179\001\210\203\242$\031\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\r\218\164\238\191\004\007address\210\203\242$!\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\015\218\164\238\191\004\tthread-id\210\203\242$,\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\brawbytes\210\171\158\194\006\012\218\164\238\191\004\006binary\210\203\242$$\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\018\218\164\238\191\004\012operand-list\218\164\238\191\004\tstd-frame\234\134\149\130\0040\242\197\227\236\003*\218\164\238\191\004\012operand-list\210\171\158\194\006\018\218\164\238\191\004\012operand-info\234\134\149\130\004\241\001\138\233\142\251\014\234\001\210\203\242$-\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\027\218\164\238\191\004\021operand-info-specific\210\203\242$\"\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\016\218\164\238\191\004\nbit-length\210\203\242$%\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\019\218\164\238\191\004\roperand-usage\210\203\242$\"\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\016\218\164\238\191\004\ntaint-info\210\203\242$)\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\005value\210\171\158\194\006\012\218\164\238\191\004\006binary\218\164\238\191\004\012operand-info\234\134\149\130\004[\170\136\200\184\014U\218\164\238\191\004\021operand-info-specific\170\183\218\222\005\023\210\171\158\194\006\017\218\164\238\191\004\011mem-operand\170\183\218\222\005\023\210\171\158\194\006\017\218\164\238\191\004\011reg-operand\234\134\149\130\004D\138\233\142\251\014>\210\203\242$(\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\004name\210\171\158\194\006\012\218\164\238\191\004\006string\218\164\238\191\004\011reg-operand\234\134\149\130\004;\138\233\142\251\0145\210\203\242$\031\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\r\218\164\238\191\004\007address\218\164\238\191\004\011mem-operand\234\134\149\130\004\202\001\138\233\142\251\014\195\001\210\203\242$&\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\004read\210\171\158\194\006\n\218\164\238\191\004\004bool\210\203\242$)\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\007written\210\171\158\194\006\n\218\164\238\191\004\004bool\210\203\242$'\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\005index\210\171\158\194\006\n\218\164\238\191\004\004bool\210\203\242$&\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\004base\210\171\158\194\006\n\218\164\238\191\004\004bool\218\164\238\191\004\roperand-usage\234\134\149\130\004^\170\136\200\184\014X\218\164\238\191\004\ntaint-info\170\183\218\222\005\014\218\164\238\191\004\bno-taint\170\183\218\222\005\020\210\171\158\194\006\014\218\164\238\191\004\btaint-id\170\183\218\222\005\020\218\164\238\191\004\014taint-multiple\234\134\149\130\004\189\001\138\233\142\251\014\182\001\210\203\242$\031\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\r\218\164\238\191\004\007address\210\203\242$!\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\015\218\164\238\191\004\tthread-id\210\203\242$*\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\006number\210\171\158\194\006\012\218\164\238\191\004\006uint64\210\203\242$%\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\019\218\164\238\191\004\rargument-list\218\164\238\191\004\rsyscall-frame\234\134\149\130\004-\242\197\227\236\003'\218\164\238\191\004\rargument-list\210\171\158\194\006\014\218\164\238\191\004\bargument\234\134\149\130\004$\130\153\170d\031\218\164\238\191\004\bargument\210\171\158\194\006\011\218\164\238\191\004\005int64\234\134\149\130\004\211\001\138\233\142\251\014\204\001\210\203\242$(\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\022\218\164\238\191\004\016exception-number\210\203\242$!\154\182\154\152\004\006\128\250\213\155\015\001\210\171\158\194\006\015\218\164\238\191\004\tthread-id\210\203\242$.\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\tfrom-addr\210\171\158\194\006\r\218\164\238\191\004\007address\210\203\242$,\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\007to-addr\210\171\158\194\006\r\218\164\238\191\004\007address\218\164\238\191\004\015exception-frame\234\134\149\130\004J\138\233\142\251\014D\210\203\242$(\154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\022\218\164\238\191\004\016taint-intro-list\218\164\238\191\004\017taint-intro-frame\234\134\149\130\0043\242\197\227\236\003-\218\164\238\191\004\016taint-intro-list\210\171\158\194\006\017\218\164\238\191\004\011taint-intro\234\134\149\130\004j\138\233\142\251\014d\210\203\242$)\154\182\154\152\004\006\248\149\210\152\t\001\218\164\238\191\004\004addr\210\171\158\194\006\r\218\164\238\191\004\007address\210\203\242$ \154\182\154\152\004\006\248\149\210\152\t\001\210\171\158\194\006\014\218\164\238\191\004\btaint-id\218\164\238\191\004\011taint-intro\234\134\149\130\004\144\001\170\136\200\184\014\137\001\218\164\238\191\004\005frame\170\183\218\222\005\021\210\171\158\194\006\015\218\164\238\191\004\tstd-frame\170\183\218\222\005\025\210\171\158\194\006\019\218\164\238\191\004\rsyscall-frame\170\183\218\222\005\027\210\171\158\194\006\021\218\164\238\191\004\015exception-frame\170\183\218\222\005\029\210\171\158\194\006\023\218\164\238\191\004\017taint-intro-frame" ]
  

