open Graphql_basic_scalars

module TransactionHash =
  Make_scalar_using_base58_check
    (Mina_transaction.Transaction_hash)
    (struct
      let name = "TransactionHash"

      let doc = "Base58Check-encoded transaction hash"
    end)
