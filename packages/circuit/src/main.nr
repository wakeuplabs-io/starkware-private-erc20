fn main(
    sender_balance: u64,         // Saldo inicial del remitente
    receiver_balance: u64,       // Saldo inicial del receptor
    transfer_amount: u64,        // Monto a transferir
    sender_new_balance: u64,     // Nuevo saldo del remitente
    receiver_new_balance: u64    // Nuevo saldo del receptor
) {
    assert(sender_balance >= transfer_amount);

    assert(sender_new_balance == sender_balance - transfer_amount);

    assert(receiver_new_balance == receiver_balance + transfer_amount);
}

#[test]
fn test_transfer_valid() {
  let sender_balance = 100;
  let receiver_balance = 50;
  let transfer_amount = 30;

  // Valores esperados
  let sender_new_balance = 70;
  let receiver_new_balance = 80;

  main(
      sender_balance,
      receiver_balance,
      transfer_amount,
      sender_new_balance,
      receiver_new_balance
  );
}

#[test(should_fail)]
fn test_insufficient_balance() {
  // Valores iniciales
  let sender_balance = 20;
  let receiver_balance = 50;
  let transfer_amount = 30;

  // Valores esperados
  let sender_new_balance = -10;
  let receiver_new_balance = 80;

  main(
    sender_balance,
    receiver_balance,
    transfer_amount,
    sender_new_balance,
    receiver_new_balance
  );
}