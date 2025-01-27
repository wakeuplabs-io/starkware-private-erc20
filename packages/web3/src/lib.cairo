#[starknet::interface]
trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> felt252;
    fn get_symbol(self: @TContractState) -> felt252;
    fn get_decimals(self: @TContractState) -> u8;
    fn get_total_supply(self: @TContractState) -> u256;
}

#[starknet::contract]
#[abi(embed_v0)]
mod ERC20 {
    // @dev library imports
    use core::num::traits::Zero;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use starknet::{contract_address_const};
    use core::starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        balances: Map<ContractAddress, u256>,
        allowances: Map<ContractAddress, Map<ContractAddress, u256>>,
    }

    // @dev emitted each time a transfer is carried out
    // @param from_ the address of the sender
    // @param to the address of the recipient
    // @param value the amount being sent
    #[event]
    fn Transfer(from_: ContractAddress, to: ContractAddress, value: u256) {}

    // @dev emitted each time an Approval operation is carried out
    // @param owner the address of the token owner
    // @param spender the address of the spender
    // @param value the amount being approved
    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    // @dev intitialized on deployment
    // @param name_ the ERC20 token name
    // @param symbol_ the ERC20 token symbol
    // @param decimals_ the ERC20 token decimals
    // @param initial_supply a Uint256 representation of the token initial supply
    // @param recipient the assigned token owner
    #[constructor]
    fn constructor(ref self: ContractState) {
        self.name.write('My First token');
        self.symbol.write('WUT');
        self.decimals.write(18);
        self.total_supply.write(1000_000000000000000000);
    }

    // @dev mints new tokens to a specific address
    // @param account the address receiving the new tokens
    // @param amount the amount of tokens to mint
    #[external(v0)]
    fn mint(ref self: ContractState, account: ContractAddress, amount: u256) {
        // Ensure the caller has permission to mint (e.g., only the contract owner)
        // let caller = get_caller_address();
        // assert(caller == self.owner.read(), "ERC20: caller is not the owner");

        // Ensure the recipient address is not zero
        assert(account.is_non_zero(), 'ERC20: mint to the zero address');

        // Update the total supply and the recipient's balance
        self.total_supply.write(self.total_supply.read() + amount);
        self.balances.entry(account).write(self.balances.entry(account).read() + amount);

        // Emit a Transfer event with the `from` address as zero to indicate minting
        Transfer(contract_address_const::<0>(), account, amount);
    }

    // @dev get name of the token
    // @return the name of the token
    fn get_name(self: @ContractState) -> felt252 {
        self.name.read()
    }

    // @dev get the symbol of the token
    // @return symbol of the token
    #[external(v0)]
    fn get_symbol(self: @ContractState) -> felt252 {
        self.symbol.read()
    }

    // @dev get the decimals of the token
    // @return decimal of the token
    #[external(v0)]
    fn get_decimals(ref self: ContractState) -> u8 {
        self.decimals.read()
    }

    // @dev get the total supply of the token
    // @return total supply of the token
    #[external(v0)]
    fn get_total_supply(ref self: ContractState) -> u256 {
        self.total_supply.read()
    }

    // @dev get the token balance of an address
    // @param account Account whose balance is to be queried
    // @return the balance of the account
    #[external(v0)]
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
        self.balances.entry(account).read()
    }

    // @dev returns the allowance to an address
    // @param owner the account whose token is to be spent
    // @param spender the spending account
    // @return remaining the amount allowed to be spent
    #[external(v0)]
    fn allowance(
        ref self: ContractState, owner: ContractAddress, spender: ContractAddress,
    ) -> u256 {
        self.allowances.entry(owner).entry(spender).read()
    }

    // @dev carries out ERC20 token transfer
    // @param recipient the address of the receiver
    // @param amount the Uint256 representation of the transaction amount
    #[external(v0)]
    fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
        let sender = get_caller_address();
        transfer_helper(ref self, sender, recipient, amount);
    }
    

    // @dev transfers token on behalf of another account
    // @param sender the from address
    // @param recipient the to address
    // @param amount the amount being sent
    #[external(v0)]
    fn transfer_from(
        ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    ) {
        let caller = get_caller_address();
        spend_allowance(ref self, sender, caller, amount);
        transfer_helper(ref self, sender, recipient, amount);
    }

    // @dev approves token to be spent on your behalf
    // @param spender address of the spender
    // @param amount amount being approved for spending
    #[external(v0)]
    fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
        let caller = get_caller_address();
        approve_helper(ref self, caller, spender, amount);
    }

    // @dev increase amount of allowed tokens to be spent on your behalf
    // @param spender address of the spender
    // @param added_value amount to be added
    fn increase_allowance(ref self: ContractState, spender: ContractAddress, added_value: u256) {
        let caller = get_caller_address();
        approve_helper(
            ref self,
            caller,
            spender,
            self.allowances.entry(caller).entry(spender).read() + added_value,
        );
    }

    // @dev increase amount of allowed tokens to be spent on your behalf
    // @param spender address of the spender
    // @param added_value amount to be added
    fn decrease_allowance(
        ref self: ContractState, spender: ContractAddress, subtracted_value: u256,
    ) {
        let caller = get_caller_address();
        approve_helper(
            ref self,
            caller,
            spender,
            self.allowances.entry(caller).entry(spender).read() - subtracted_value,
        );
    }

    // @dev internal function that performs the transfer logic
    // @param sender address of the sender
    // @param recipient the address of the receiver
    // @param amount the Uint256 representation of the transaction amount
    fn transfer_helper(
        ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    ) {
        assert(sender.is_non_zero(), 'ERC20: transfer from 0');
        assert(recipient.is_non_zero(), 'ERC20: transfer to 0');
        self.balances.entry(sender).write(self.balances.entry(sender).read() - amount);
        self.balances.entry(recipient).write(self.balances.entry(recipient).read() + amount);
        Transfer(sender, recipient, amount);
    }

    // @dev infinite allowance check
    // @param owner the address of the token owner
    // @param spender the address of the spender
    // @param amount the Uint256 representation of the approved amount
    fn spend_allowance(
        ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256,
    ) {
        let current_allowance = self.allowances.entry(owner).entry(spender).read();
        let ONES_MASK = 0xffffffffffffffffffffffffffffffff_u128;
        let is_unlimited_allowance = (current_allowance.low == ONES_MASK)
            && (current_allowance.high == ONES_MASK);
        if !is_unlimited_allowance {
            approve_helper(ref self, owner, spender, current_allowance - amount);
        }
    }

    // @dev internal function that performs the approval logic
    // @param owner the address of the token owner
    // @param spender the address of the spender
    // @param amount the Uint256 representation of the approved amount
    fn approve_helper(
        ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256,
    ) {
        assert(spender.is_non_zero(), 'ERC20: approve from 0');
        self.allowances.entry(owner).entry(spender).write(amount);
        Approval(owner, spender, amount);
    }
}
