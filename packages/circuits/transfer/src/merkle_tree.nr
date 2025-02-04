use std::hash::poseidon2::Poseidon2::hash;

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

        digest = hash([left, right], 2);
    }

    assert(digest == root);
}

// #[test]
// fn test_merkle_inclusion() {
//     let commitment: Field = hash([123456], 1);
//     let leafs: [Field; 4] = [
//         commitment,
//         hash([0], 1),
//         hash([0], 1),
//         hash([0], 1),
//     ];


//     let second_level_l = hash([leafs[0], leafs[1]], 2);
//     let second_level_r = hash([leafs[2], leafs[3]], 2);
//     let root = hash([second_level_l, second_level_r], 2);
//     let path: [Field; DEPTH] = [
//         leafs[1], second_level_r,
//     ];
//     let direction_selector: [bool; DEPTH] = [
//         false, false, 
//     ];

//     merkle_inclusion(root, path, direction_selector, commitment);
// }
