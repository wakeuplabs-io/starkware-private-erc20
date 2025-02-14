import { Abi } from "starknet";

export const PRIVATE_ERC20_DEPLOY_BLOCK = 521743;
export const PRIVATE_ERC20_EVENT_KEY =
  "contracts::privado::privado::Privado::Approval";
export const PRIVATE_ERC20_CONTRACT_ADDRESS =
  "0x001782bd503e83475fac46fc3d89fc60c812878ecf00c1e52289bba52d7cadfc";
export const ZERO_BIG_INT = BigInt(0);
export const MERKLE_TREE_DEPTH = 12;
export const DECIMALS = 6n;

export const PRIVATE_ERC20_ABI: Abi = [
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
    "name": "core::byte_array::ByteArray",
    "type": "struct",
    "members": [
      {
        "name": "data",
        "type": "core::array::Array::<core::bytes_31::bytes31>"
      },
      {
        "name": "pending_word",
        "type": "core::felt252"
      },
      {
        "name": "pending_word_len",
        "type": "core::integer::u32"
      }
    ]
  },
  {
    "name": "core::array::Span::<core::byte_array::ByteArray>",
    "type": "struct",
    "members": [
      {
        "name": "snapshot",
        "type": "@core::array::Array::<core::byte_array::ByteArray>"
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
            "name": "proof",
            "type": "core::array::Span::<core::felt252>"
          },
          {
            "name": "enc_notes_output",
            "type": "core::array::Span::<core::byte_array::ByteArray>"
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
            "name": "relationship_hash",
            "type": "core::integer::u256"
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
            "name": "proof",
            "type": "core::array::Span::<core::felt252>"
          },
          {
            "name": "enc_notes_output",
            "type": "core::array::Span::<core::byte_array::ByteArray>"
          },
          {
            "name": "enc_approval_output",
            "type": "core::array::Span::<core::byte_array::ByteArray>"
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
            "name": "proof",
            "type": "core::array::Span::<core::felt252>"
          },
          {
            "name": "enc_approval_output",
            "type": "core::array::Span::<core::byte_array::ByteArray>"
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
        "name": "current_root",
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
        "name": "current_commitment_index",
        "type": "function",
        "inputs": [],
        "outputs": [
          {
            "type": "core::integer::u256"
          }
        ],
        "state_mutability": "view"
      }
    ]
  },
  {
    "name": "constructor",
    "type": "constructor",
    "inputs": []
  },
  {
    "kind": "struct",
    "name": "contracts::privado::privado::Privado::NewCommitment",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "commitment",
        "type": "core::integer::u256"
      },
      {
        "kind": "data",
        "name": "output_enc",
        "type": "core::byte_array::ByteArray"
      },
      {
        "kind": "data",
        "name": "index",
        "type": "core::integer::u256"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "contracts::privado::privado::Privado::NewSpendingTracker",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "spending_tracker",
        "type": "core::integer::u256"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "contracts::privado::privado::Privado::Approval",
    "type": "event",
    "members": [
      {
        "kind": "key",
        "name": "allowance_relationship",
        "type": "core::integer::u256"
      },
      {
        "kind": "data",
        "name": "timestamp",
        "type": "core::integer::u64"
      },
      {
        "kind": "data",
        "name": "allowance_hash",
        "type": "core::integer::u256"
      },
      {
        "kind": "data",
        "name": "output_enc_owner",
        "type": "core::byte_array::ByteArray"
      },
      {
        "kind": "data",
        "name": "output_enc_spender",
        "type": "core::byte_array::ByteArray"
      }
    ]
  },
  {
    "kind": "enum",
    "name": "contracts::privado::privado::Privado::Event",
    "type": "event",
    "variants": [
      {
        "kind": "nested",
        "name": "NewCommitment",
        "type": "contracts::privado::privado::Privado::NewCommitment"
      },
      {
        "kind": "nested",
        "name": "NewSpendingTracker",
        "type": "contracts::privado::privado::Privado::NewSpendingTracker"
      },
      {
        "kind": "nested",
        "name": "Approval",
        "type": "contracts::privado::privado::Privado::Approval"
      }
    ]
  }
]