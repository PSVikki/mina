open Ppxlib
open Core_kernel

module Parties_templates = struct
  let pooled_zkapp_commands =
    Printf.sprintf
      {graphql|
    query zkapp_commands($public_key: PublicKey) {
      pooledZkappCommands(publicKey: $public_key) {
        id
        hash
        failureReason {
                         index
                         failures
                       }
        parties %s
      }
    }|graphql}

  let internal_send_zkapp =
    Printf.sprintf
      {|
         mutation ($parties: SendTestZkappInput!) {
            internalSendZkapp(parties: $parties) {
               zkapp { id
                       hash
                       failureReason {
                         index
                         failures
                       }
                       parties %s
                     }
             }
         }
      |}
end

let party_query_expr template ~loc =
  let module E = Ppxlib.Ast_builder.Make (struct
    let loc = loc
  end) in
  let open E in
  estring @@ template (Lazy.force Mina_base.Parties.inner_query)

let structure ~loc =
  let module E = Ppxlib.Ast_builder.Make (struct
    let loc = loc
  end) in
  let open E in
  let node_builder f =
    let exp = party_query_expr f ~loc in
    let str = [ E.pstr_eval exp [] ] in
    E.pmod_extension (E.Located.mk "graphql", PStr str)
  in
  let m1_node = node_builder Parties_templates.pooled_zkapp_commands in
  let m2_node = node_builder Parties_templates.internal_send_zkapp in
  let modname s = E.Located.mk (Some s) in
  E.
    [ module_binding ~name:(modname "Pooled_zkapp_commands") ~expr:m1_node
    ; module_binding ~name:(modname "Send_test_zkapp") ~expr:m2_node
    ]
  |> List.map ~f:E.pstr_module

let main () =
  Out_channel.with_file "generated_graphql_queries.ml" ~f:(fun ml_file ->
      let fmt = Format.formatter_of_out_channel ml_file in
      Pprintast.top_phrase fmt (Ptop_def (structure ~loc:Ppxlib.Location.none)) )

let () = main ()
