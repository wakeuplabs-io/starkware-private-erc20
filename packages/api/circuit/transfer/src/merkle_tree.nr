use std::hash::poseidon2;

global DEPTH: u32 = 4;

pub fn merkle_inclusion(
    root: Field,
    path: [Field; DEPTH],
    direction_selector: [bool; DEPTH],
    commitment: Field,
) {
    let mut digest = commitment;
    
    for i in 0..DEPTH {
        let (left, right) = if direction_selector[i] {

            (path[i], digest)
        } else {
            (digest, path[i])
        };
        digest = poseidon2::Poseidon2::hash([left, right], 2);
    }

    assert(digest == root);
}

pub fn merkle_inclusion_with_index(
    root : Field,
    commitment: Field,
    path : [Field; DEPTH],
    index : Field,
) {
    let merkle_root = std::merkle::compute_merkle_root(commitment, index, path);
    println(merkle_root);
    println(root);
    assert(merkle_root == root);
}
