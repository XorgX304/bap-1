open Ast
open Ast_convenience
open Grammar_scope
open Type
open Vc
open Utils_common

let usage = "Usage: "^Sys.argv.(0)^" <input options> [-o output]\n\
             Translate programs to the IL. "

let fast_fse = ref false
let options = ref Vc.default_options
let irout = ref(Some stdout)
let post = ref "true"
let stpout = ref None
let stpoutname = ref ""
let pstpout = ref None
let suffix = ref ""
let usedc = ref true
let usesccvn = ref true
let solve = ref false
(* let dwpcf = ref true *)
(* let sat = ref true *)

(* Select which solver to use *)
let solver = ref (Smtexec.STP.si);;

(* DWP paper *)

let set_solver s =
  solver := try Hashtbl.find Smtexec.solvers s
  with Not_found ->
    failwith "Unknown solver"

let solvers = Hashtbl.fold (fun k _ s -> k ^ " " ^ s) Smtexec.solvers ""

let vc = ref compute_wp_gen

let speclist =
  ("-o", Arg.String (fun f -> irout := Some(open_out f)),
   "<file> Print output to <file> rather than stdout.")
  ::("-stp-out", Arg.String (fun f -> stpoutname := f; stpout := Some(open_out f)),
     "<file> Print output to <file> rather than stdout.")
  ::("-pstp-out", Arg.String (fun f -> pstpout := Some(open_out f)),
     "<file> Print WP expression without assertion to <file>.")
  ::("-q", Arg.Unit (fun () -> irout := None),
     "Quiet: Supress outputting the WP in the BAP IL.")
  ::("-post", Arg.Set_string post,
     "<exp> Use <exp> as the postcondition (defaults to \"true\")")
  ::("-suffix", Arg.String (fun str -> suffix := str),
     "<suffix> Add <suffix> to each variable name.")
  ::("-dwp", Arg.Unit(fun()-> vc := compute_dwp_gen),
     "Use efficient directionless weakest precondition")
  ::("-fwp", Arg.Unit(fun()-> vc := compute_fwp_gen),
     "Use simple forward weakest precondition")
  ::("-eddwp", Arg.Unit(fun()-> vc := compute_eddwp_gen),
     "Use Ed's efficient directionless weakest precondition algorithm")
  ::("-eddwplazyconc", Arg.Unit(fun()-> vc := compute_eddwp_lazyconc_gen),
     "Use Ed's efficient directionless weakest precondition algorithm with concrete evaluation and lazy merging")
  ::("-dwpk", Arg.Int(fun i-> vc := compute_dwp_gen;
    options := {!options with k=i};
),
     "Use efficient directionless weakest precondition")
  ::("-dwp1", Arg.Unit(fun()-> vc := compute_dwp1_gen),
     "Use 1st order efficient directionless weakest precondition")
  ::("-flanagansaxe", Arg.Unit(fun()-> vc := compute_flanagansaxe_gen),
     "Use Flanagan & Saxe's algorithm instead of the default WP.")
  ::("-wp", Arg.Unit(fun()-> vc := compute_wp_gen),
     "Use Dijkstra's WP on GCL.")
  ::("-pwp", Arg.Unit(fun()-> vc := compute_passified_wp_gen),
     "Efficient WP on passified GCL programs.")
  ::("-uwp", Arg.Unit(fun()-> vc := compute_uwp_gen),
     "Use WP for Unstructured Programs")
  ::("-uwpe", Arg.Unit(fun()-> vc := compute_uwp_efficient_gen),
     "Use efficient WP for Unstructured Programs")
  ::("-fse-unpass-dwp-paper", Arg.Unit(fun () -> vc := compute_fse_unpass_gen),
     "Use inefficient FSE algorithm for unpassified programs in DWP paper.")
  ::("-fse-pass-dwp-paper", Arg.Unit(fun () -> vc := compute_fse_pass_gen),
     "Use inefficient FSE algorithm for passified programs in DWP paper.")
  ::("-efse-pass-dwp-paper", Arg.Unit(fun () -> vc := compute_efse_pass_gen),
     "Use efficient FSE algorithm for passified programs in DWP paper.")
  ::("-efse-pass-merge-dwp-paper", Arg.Unit(fun () -> vc := compute_efse_mergepass_gen),
     "Use efficient FSE algorithm for passified programs in DWP paper that adds concrete assignments to the formula only during merging.")
  ::("-efse-pass-lazy-dwp-paper", Arg.Unit(fun () -> vc := compute_efse_lazypass_gen),
     "Use efficient FSE algorithm for passified programs in DWP paper that lazily adds concrete assignments to the formula when merging.")
  (* ::("-efse-pass-feas-dwp-paper", Arg.Unit(fun () -> vc := compute_efse_feaspass), *)
  (*    "Use efficient FSE algorithm for passified programs in DWP paper with feasibility checking.") *)
  ::("-nocf-dwp-paper", Arg.Unit(fun () -> options := {!options with cf = false}),
     "Do not use constant folding in DWP paper algorithms")
  ::("-fse-bfs", Arg.Unit(fun()-> vc := compute_fse_bfs_gen),
     "Use naive forward symbolic execution with breath first search")
  ::("-fse-bfs-maxdepth", Arg.Int(fun i-> vc := compute_fse_bfs_maxdepth_gen i),
     "<n> FSE with breath first search, limiting search depth to n.")
  ::("-fse-maxrepeat", Arg.Int(fun i-> vc := compute_fse_maxrepeat_gen i),
     "<n> FSE excluding walks that visit a point more than n times.")
  ::("-fse-fast", Arg.Set fast_fse,
     "Perform FSE without full substitution.")
  ::("-solver", Arg.String set_solver,
     ("Use the specified solver. Choices: " ^ solvers))
  ::("-noopt", Arg.Unit (fun () -> usedc := false; usesccvn := false),
     "Do not perform any optimizations on the SSA CFG.")
  ::("-opt", Arg.Unit (fun () -> usedc := true; usesccvn := true),
     "Perform all optimizations on the SSA CFG.")
  ::("-optdc", Arg.Unit (fun () -> usedc := true; usesccvn := false),
     "Perform deadcode elimination on the SSA CFG.")
  ::("-optsccvn", Arg.Unit (fun () -> usedc := false; usesccvn := true),
     "Perform sccvn on the SSA CFG.")
  ::("-solve", Arg.Unit (fun () -> solve := true),
     "Solve the generated formula.")
  ::("-validity", Arg.Unit (fun () -> options := {!options with mode = Type.Validity}),
     "Check for validity.")
  ::("-sat", Arg.Unit (fun () -> options := {!options with mode = Type.Sat}),
     "Check for satisfiability.")
  :: Input.speclist

let () = Tunegc.set_gc ()
let anon x = raise(Arg.Bad("Unexpected argument: '"^x^"'"))
let () = Arg.parse speclist anon usage

let m2a_state = Memory2array.create_state ()

let prog,scope =
  try Input.get_program()
  with Arg.Bad s ->
    Arg.usage speclist (s^"\n"^usage);
    exit 1

let post,scope = Parser.exp_from_string ~scope !post

let prog = Memory2array.coerce_prog_state ~scope m2a_state prog
let post = Memory2array.coerce_exp_state ~scope m2a_state post

let cfg = Cfg_ast.of_prog prog
let cfg = Prune_unreachable.prune_unreachable_ast cfg
;;
let (wp, foralls) =
  if !usedc || !usesccvn then
    let () = print_endline "Applying optimizations..." in
    let {Cfg_ssa.cfg=ssacfg; to_ssavar=tossa} = Cfg_ssa.trans_cfg cfg in
    let () = Pp.output_varnums := true in
    let post = rename_astexp tossa post in
    let freevars = Formulap.freevars post in
    let ssacfg = Ssa_simp.simp_cfg ~liveout:freevars ~usedc:!usedc ~usesccvn:!usesccvn ssacfg in
    let () = print_endline "Computing predicate..." in
    vc_ssacfg !vc !options ssacfg post
  else
    let () = print_endline "Computing predicate..." in
    vc_astcfg !vc !options cfg post
;;

match !irout with
| None -> ()
| Some oc ->
  let () = print_endline "Printing predicate as BAP expression" in
  let p = new Pp.pp_oc oc in
  let () = p#ast_exp wp in
  p#close
;;
match !stpout with
| None -> ()
| Some oc ->
  let () = print_endline "Printing predicate as SMT formula" in
  let foralls = List.map (Memory2array.coerce_rvar_state ~scope m2a_state) foralls in 
  let pp = (((!solver)#printer) :> Formulap.fppf) in
  let p = pp ~suffix:!suffix oc in
  (match !options with
  | {mode=Sat} ->
    p#assert_ast_exp ~foralls wp
  | {mode=Validity} ->
    p#valid_ast_exp ~foralls wp
  | {mode=Foralls} ->
    failwith "Foralls formula mode unsupported at this level");
  p#counterexample;
  p#close;
  if !solve then (
    Printf.fprintf stderr "Solving\n"; flush stderr;
    let r = (!solver)#solve_formula_file ~printmodel:true !stpoutname in
    Printf.fprintf stderr "Solve result: %s\n" (Smtexec.result_to_string r))

;;
match !pstpout with
| None -> ()
| Some oc ->
  let () = print_endline "Printing predicate as SMT formula" in
  let foralls = List.map (Memory2array.coerce_rvar_state m2a_state) foralls in 
  let pp = (((!solver)#printer) :> Formulap.fppf) in
  let p = pp ~suffix:!suffix oc in
  p#forall foralls;
  p#ast_exp wp;
  p#close
;;

