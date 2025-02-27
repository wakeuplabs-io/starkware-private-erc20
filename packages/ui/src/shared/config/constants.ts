import { Abi } from "starknet";

// Enigma contract
export const ENIGMA_DEPLOY_BLOCK = 524850;
export const ENIGMA_APPROVAL_EVENT_KEY = "contracts::privado::privado::Privado::Approval";
export const ENIGMA_CONTRACT_ADDRESS = "0x0243720b953ca3ef84dfdb24408cc1ff2941afe4b3fadad19ccb04ec10ddab2b";
export const ENIGMA_DECIMALS = 6n;
export const MERKLE_TREE_DEPTH = 12;

// deposit
export const ETH_CONTRACT_ADDRESS = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7";
export const ENG_TO_ETH_RATE = 1_000_000_000_000n;  // 10000000000000 ETH
export const ETH_TO_ENG_RATE = 1_000_000_000_000_000_000n; // 1000000000000000000 ENG
export const WEI_TO_ENG = 1_000_000_000_000n;


export const ENIGMA_ABI: Abi =[
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
        "name": "deposit",
        "type": "function",
        "inputs": [
          {
            "name": "proof",
            "type": "core::array::Span::<core::felt252>"
          },
          {
            "name": "receiver_enc_output",
            "type": "core::byte_array::ByteArray"
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
    "name": "contracts::privado::privado::Privado::NewNullifier",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "nullifier",
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
        "name": "NewNullifier",
        "type": "contracts::privado::privado::Privado::NewNullifier"
      },
      {
        "kind": "nested",
        "name": "Approval",
        "type": "contracts::privado::privado::Privado::Approval"
      }
    ]
  }
];

export const ETH_ABI: Abi = [
  {
    "name": "MintableToken",
    "type": "impl",
    "interface_name": "src::mintable_token_interface::IMintableToken"
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
    "name": "src::mintable_token_interface::IMintableToken",
    "type": "interface",
    "items": [
      {
        "name": "permissioned_mint",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          },
          {
            "name": "amount",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "permissioned_burn",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          },
          {
            "name": "amount",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      }
    ]
  },
  {
    "name": "MintableTokenCamelImpl",
    "type": "impl",
    "interface_name": "src::mintable_token_interface::IMintableTokenCamel"
  },
  {
    "name": "src::mintable_token_interface::IMintableTokenCamel",
    "type": "interface",
    "items": [
      {
        "name": "permissionedMint",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          },
          {
            "name": "amount",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "permissionedBurn",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          },
          {
            "name": "amount",
            "type": "core::integer::u256"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      }
    ]
  },
  {
    "name": "Replaceable",
    "type": "impl",
    "interface_name": "src::replaceability_interface::IReplaceable"
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
    "name": "src::replaceability_interface::EICData",
    "type": "struct",
    "members": [
      {
        "name": "eic_hash",
        "type": "core::starknet::class_hash::ClassHash"
      },
      {
        "name": "eic_init_data",
        "type": "core::array::Span::<core::felt252>"
      }
    ]
  },
  {
    "name": "core::option::Option::<src::replaceability_interface::EICData>",
    "type": "enum",
    "variants": [
      {
        "name": "Some",
        "type": "src::replaceability_interface::EICData"
      },
      {
        "name": "None",
        "type": "()"
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
    "name": "src::replaceability_interface::ImplementationData",
    "type": "struct",
    "members": [
      {
        "name": "impl_hash",
        "type": "core::starknet::class_hash::ClassHash"
      },
      {
        "name": "eic_data",
        "type": "core::option::Option::<src::replaceability_interface::EICData>"
      },
      {
        "name": "final",
        "type": "core::bool"
      }
    ]
  },
  {
    "name": "src::replaceability_interface::IReplaceable",
    "type": "interface",
    "items": [
      {
        "name": "get_upgrade_delay",
        "type": "function",
        "inputs": [],
        "outputs": [
          {
            "type": "core::integer::u64"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "get_impl_activation_time",
        "type": "function",
        "inputs": [
          {
            "name": "implementation_data",
            "type": "src::replaceability_interface::ImplementationData"
          }
        ],
        "outputs": [
          {
            "type": "core::integer::u64"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "add_new_implementation",
        "type": "function",
        "inputs": [
          {
            "name": "implementation_data",
            "type": "src::replaceability_interface::ImplementationData"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "remove_implementation",
        "type": "function",
        "inputs": [
          {
            "name": "implementation_data",
            "type": "src::replaceability_interface::ImplementationData"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "replace_to",
        "type": "function",
        "inputs": [
          {
            "name": "implementation_data",
            "type": "src::replaceability_interface::ImplementationData"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      }
    ]
  },
  {
    "name": "AccessControlImplExternal",
    "type": "impl",
    "interface_name": "src::access_control_interface::IAccessControl"
  },
  {
    "name": "src::access_control_interface::IAccessControl",
    "type": "interface",
    "items": [
      {
        "name": "has_role",
        "type": "function",
        "inputs": [
          {
            "name": "role",
            "type": "core::felt252"
          },
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [
          {
            "type": "core::bool"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "get_role_admin",
        "type": "function",
        "inputs": [
          {
            "name": "role",
            "type": "core::felt252"
          }
        ],
        "outputs": [
          {
            "type": "core::felt252"
          }
        ],
        "state_mutability": "view"
      }
    ]
  },
  {
    "name": "RolesImpl",
    "type": "impl",
    "interface_name": "src::roles_interface::IMinimalRoles"
  },
  {
    "name": "src::roles_interface::IMinimalRoles",
    "type": "interface",
    "items": [
      {
        "name": "is_governance_admin",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [
          {
            "type": "core::bool"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "is_upgrade_governor",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [
          {
            "type": "core::bool"
          }
        ],
        "state_mutability": "view"
      },
      {
        "name": "register_governance_admin",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "remove_governance_admin",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "register_upgrade_governor",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "remove_upgrade_governor",
        "type": "function",
        "inputs": [
          {
            "name": "account",
            "type": "core::starknet::contract_address::ContractAddress"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      },
      {
        "name": "renounce",
        "type": "function",
        "inputs": [
          {
            "name": "role",
            "type": "core::felt252"
          }
        ],
        "outputs": [],
        "state_mutability": "external"
      }
    ]
  },
  {
    "name": "ERC20Impl",
    "type": "impl",
    "interface_name": "openzeppelin::token::erc20::interface::IERC20"
  },
  {
    "name": "openzeppelin::token::erc20::interface::IERC20",
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
        "name": "transfer",
        "type": "function",
        "inputs": [
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
    "name": "ERC20CamelOnlyImpl",
    "type": "impl",
    "interface_name": "openzeppelin::token::erc20::interface::IERC20CamelOnly"
  },
  {
    "name": "openzeppelin::token::erc20::interface::IERC20CamelOnly",
    "type": "interface",
    "items": [
      {
        "name": "totalSupply",
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
        "name": "balanceOf",
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
        "name": "transferFrom",
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
        "name": "initial_supply",
        "type": "core::integer::u256"
      },
      {
        "name": "recipient",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "permitted_minter",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "provisional_governance_admin",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "upgrade_delay",
        "type": "core::integer::u64"
      }
    ]
  },
  {
    "name": "increase_allowance",
    "type": "function",
    "inputs": [
      {
        "name": "spender",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "added_value",
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
    "name": "decrease_allowance",
    "type": "function",
    "inputs": [
      {
        "name": "spender",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "subtracted_value",
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
    "name": "increaseAllowance",
    "type": "function",
    "inputs": [
      {
        "name": "spender",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "addedValue",
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
    "name": "decreaseAllowance",
    "type": "function",
    "inputs": [
      {
        "name": "spender",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "name": "subtractedValue",
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
    "kind": "struct",
    "name": "openzeppelin::token::erc20_v070::erc20::ERC20::Transfer",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "from",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "to",
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
    "kind": "struct",
    "name": "openzeppelin::token::erc20_v070::erc20::ERC20::Approval",
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
    "kind": "struct",
    "name": "src::replaceability_interface::ImplementationAdded",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "implementation_data",
        "type": "src::replaceability_interface::ImplementationData"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::replaceability_interface::ImplementationRemoved",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "implementation_data",
        "type": "src::replaceability_interface::ImplementationData"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::replaceability_interface::ImplementationReplaced",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "implementation_data",
        "type": "src::replaceability_interface::ImplementationData"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::replaceability_interface::ImplementationFinalized",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "impl_hash",
        "type": "core::starknet::class_hash::ClassHash"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::access_control_interface::RoleGranted",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "role",
        "type": "core::felt252"
      },
      {
        "kind": "data",
        "name": "account",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "sender",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::access_control_interface::RoleRevoked",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "role",
        "type": "core::felt252"
      },
      {
        "kind": "data",
        "name": "account",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "sender",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::access_control_interface::RoleAdminChanged",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "role",
        "type": "core::felt252"
      },
      {
        "kind": "data",
        "name": "previous_admin_role",
        "type": "core::felt252"
      },
      {
        "kind": "data",
        "name": "new_admin_role",
        "type": "core::felt252"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::roles_interface::GovernanceAdminAdded",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "added_account",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "added_by",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::roles_interface::GovernanceAdminRemoved",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "removed_account",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "removed_by",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::roles_interface::UpgradeGovernorAdded",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "added_account",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "added_by",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ]
  },
  {
    "kind": "struct",
    "name": "src::roles_interface::UpgradeGovernorRemoved",
    "type": "event",
    "members": [
      {
        "kind": "data",
        "name": "removed_account",
        "type": "core::starknet::contract_address::ContractAddress"
      },
      {
        "kind": "data",
        "name": "removed_by",
        "type": "core::starknet::contract_address::ContractAddress"
      }
    ]
  },
  {
    "kind": "enum",
    "name": "openzeppelin::token::erc20_v070::erc20::ERC20::Event",
    "type": "event",
    "variants": [
      {
        "kind": "nested",
        "name": "Transfer",
        "type": "openzeppelin::token::erc20_v070::erc20::ERC20::Transfer"
      },
      {
        "kind": "nested",
        "name": "Approval",
        "type": "openzeppelin::token::erc20_v070::erc20::ERC20::Approval"
      },
      {
        "kind": "nested",
        "name": "ImplementationAdded",
        "type": "src::replaceability_interface::ImplementationAdded"
      },
      {
        "kind": "nested",
        "name": "ImplementationRemoved",
        "type": "src::replaceability_interface::ImplementationRemoved"
      },
      {
        "kind": "nested",
        "name": "ImplementationReplaced",
        "type": "src::replaceability_interface::ImplementationReplaced"
      },
      {
        "kind": "nested",
        "name": "ImplementationFinalized",
        "type": "src::replaceability_interface::ImplementationFinalized"
      },
      {
        "kind": "nested",
        "name": "RoleGranted",
        "type": "src::access_control_interface::RoleGranted"
      },
      {
        "kind": "nested",
        "name": "RoleRevoked",
        "type": "src::access_control_interface::RoleRevoked"
      },
      {
        "kind": "nested",
        "name": "RoleAdminChanged",
        "type": "src::access_control_interface::RoleAdminChanged"
      },
      {
        "kind": "nested",
        "name": "GovernanceAdminAdded",
        "type": "src::roles_interface::GovernanceAdminAdded"
      },
      {
        "kind": "nested",
        "name": "GovernanceAdminRemoved",
        "type": "src::roles_interface::GovernanceAdminRemoved"
      },
      {
        "kind": "nested",
        "name": "UpgradeGovernorAdded",
        "type": "src::roles_interface::UpgradeGovernorAdded"
      },
      {
        "kind": "nested",
        "name": "UpgradeGovernorRemoved",
        "type": "src::roles_interface::UpgradeGovernorRemoved"
      }
    ]
  }
];
