use std::hash::poseidon;

global DEPTH: u32 = 2;

pub fn merkle_inclusion(
    root: Field,
    commitment: Field,
    path: [Field; DEPTH],
    direction_selector: [bool; DEPTH]
) {
    let mut digest = commitment;

    for i in 0..DEPTH {
        let (left, right) = if direction_selector[i] {
            (path[i], digest)
            
        } else {
            (digest, path[i])
        };
        digest = poseidon::bn254::hash_2([left, right]);
    }

    assert(digest == root);
}

#[test]
fn test_merkle_inclusion() {
    let commitment: Field = poseidon::bn254::hash_1([123456]);
    let leafs: [Field; 4] = [
        commitment,
        poseidon::bn254::hash_1([2]),
        poseidon::bn254::hash_1([3]),
        poseidon::bn254::hash_1([4]),
    ];


    let second_level_1 = poseidon::bn254::hash_2([leafs[0], leafs[1]]);
    let second_level_2 = poseidon::bn254::hash_2([leafs[2], leafs[3]]);
    let root = poseidon::bn254::hash_2([second_level_1, second_level_2]);
    let path: [Field; DEPTH] = [
        leafs[1], second_level_2,
    ];
    let direction_selector: [bool; DEPTH] = [
        false, false
    ];

    merkle_inclusion(root, commitment, path, direction_selector);
}
