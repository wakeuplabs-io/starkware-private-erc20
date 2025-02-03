import { Abi } from "starknet";

const privateTokenAbi: Abi = [
  {
    "name": "PrivadoImpl",
    "type": "impl",
    "interface_name": "contracts::privado::privado::IPrivado"
  },
  {
    "name": "core::integer::u256",
    "type": "struct",
    "members": [
      {
        "name": "low",
        "type": "core::integer::u128"
      },
      {
        "name": "high",
        "type": "core::integer::u128"
      }
    ]
  },
  {
    "name": "core::array::Span::<core::felt252>",
    "type": "struct",
    "members": [
      {
        "name": "snapshot",
        "type": "@core::array::Array::<core::felt252>"
      }
    ]
  },
  {
    "name": "core::bool",
    "type": "enum",
    "variants": [
      {
        "name": "False",
        "type": "()"
      },
      {
        "name": "True",
        "type": "()"
      }
    ]
  },
  {
    "name": "contracts::privado::privado::IPrivado",
    "type": "interface",
    "items": [
      {
        "name": "name",
        "type": "function",
        "inputs": [],
        "outputs": [
          {
            "type": "core::felt252"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "symbol",
        "type": "function",
        "inputs": [],
        "outputs": [
          {
            "type": "core::felt252"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "decimals",
        "type": "function",
        "inputs": [],
        "outputs": [
          {
            "type": "core::integer::u8"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "total_supply",
        "type": "function",
        "inputs": [],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "balance_of",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "transfer",
        "type": "function",
        "inputs": [
          {
            "name": "root",
            "type": "core::felt252"
          },
          {
            "name": "nullifier_hash",
            "type": "core::felt252"
          },
          {
            "name": "sender_commitment",
            "type": "core::felt252"
          },
          {
            "name": "sender_amount_enc",
            "type": "core::felt252"
          },
          {
            "name": "receiver_commitment",
            "type": "core::felt252"
          },
          {
            "name": "receiver_amount_enc",
            "type": "core::felt252"
          },
          {
            "name": "full_proof_with_hints",
            "type": "core::array::Span::<core::felt252>"
          }
        ],
        "outputs": [
          {
            "type": "core::bool"
          }
        ],
        "state_mutability": "external"
      },
      {
        "name": "allowance",
        "type": "function",
        "inputs": [
          {
            "name": "owner",
            "type": "core::starknet::contract_address::ContractAddress"
          },
          {
            "name": "spender",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "transfer_from",
        "type": "function",
        "inputs": [
          {
            "name": "sender",
            "type": "core::starknet::contract_address::ContractAddress"
          },
          {
            "name": "recipient",
            "type": "core::starknet::contract_address::ContractAddress"
          },
          {
            "name": "amount",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [
          {
            "type": "core::bool"
          }
        ],
        "state_mutability": "external"
      },
      {
        "name": "approve",
        "type": "function",
        "inputs": [
          {
            "name": "spender",
            "type": "core::starknet::contract_address::ContractAddress"
          },
          {
            "name": "amount",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [
          {
            "type": "core::bool"
          }
        ],
        "state_mutability": "external"
      }
    ]
  },
  {
    "name": "constructor",
    "type": "constructor",
    "inputs": [
      {
        "name": "name",
        "type": "core::felt252"
      },
      {
        "name": "symbol",
        "type": "core::felt252"
      },
      {
        "name": "decimals",
        "type": "core::integer::u8"
      },
      {
        "name": "levels",
        "type": "core::integer::u32"
      },
      {
        "name": "mint_commitment",
        "type": "core::felt252"
      },
      {
        "name": "mint_amount_enc",
        "type": "core::felt252"
      },
      {
        "name": "verifier_address",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "contracts::privado::privado::Privado::NewNote",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "commitment",
        "type": "core::felt252"
      },
      {
        "kind": "data",
        "name": "amount_enc",
        "type": "core::felt252"
      },
      {
        "kind": "data",
        "name": "index",
        "type": "core::integer::u32"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "contracts::privado::privado::Privado::Approval",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "owner",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "spender",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "value",
        "type": "core::integer::u256"
      }
    ]
  },
  {
    "kind": "enum",
    "name": "contracts::merkle_tree::merkle_tree::MerkleTreeWithHistoryComponent::Event",
    "type": "event",
    "variants": []
  },
  {
    "kind": "enum",
    "name": "contracts::privado::privado::Privado::Event",
    "type": "event",
    "variants": [
      {
        "kind": "nested",
        "name": "NewNote",
        "type": "contracts::privado::privado::Privado::NewNote"
      },
      {
        "kind": "nested",
        "name": "Approval",
        "type": "contracts::privado::privado::Privado::Approval"
      },
      {
        "kind": "nested",
        "name": "MerkleTreeEvent",
        "type": "contracts::merkle_tree::merkle_tree::MerkleTreeWithHistoryComponent::Event"
      }
    ]
  }
];

export default privateTokenAbi;
