pub mod privado {
    pub mod privado;
    pub use privado::*;
    pub mod constants;
    pub use constants::*;
}

pub mod verifiers {
    pub mod approve;
    pub use approve::*;
    pub mod transfer;
    pub use transfer::*;
    pub mod transfer_from;
    pub use transfer_from::*;
    pub mod deposit;
    pub use deposit::*;
}

pub mod erc20 {
    pub mod eth;
    pub use eth::*;
}

