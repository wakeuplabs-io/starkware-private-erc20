use std::hash::poseidon2::Poseidon2::hash;
global DEPTH: u32 = 2;

pub fn assert_merkle_inclusion(
    root: Field,
    path: [Field],
    direction_selector: [bool],
    commitment: Field,
) {
    assert(path.len() == direction_selector.len());
    
    let mut digest = commitment;
    for i in 0..path.len() {
        let (left, right) = if direction_selector[i] {
            (path[i], digest)
        } else {
            (digest, path[i])
        };

        digest = hash([left, right], 2);
    }

    assert(digest == root);
}

#[test]
fn should_included() {
    let first_level_l = hash([hash([1], 1), hash([0], 1)], 2);
    let first_level_r = hash([hash([0], 1), hash([0], 1)], 2);
    let root = hash([first_level_l, first_level_r], 2);

    let path: [Field; 2] = [ hash([0], 1), first_level_r ];
    let direction_selector: [bool; 2] = [ false, false ];

    assert_merkle_inclusion(root, path, direction_selector, hash([1], 1));
}


#[test(should_fail)]
fn should_not_included() {
    let first_level_l = hash([hash([1], 1), hash([0], 1)], 2);
    let first_level_r = hash([hash([0], 1), hash([0], 1)], 2);
    let root = hash([first_level_l, first_level_r], 2);

    let path: [Field; 2] = [ hash([0], 1), first_level_r ];
    let direction_selector: [bool; 2] = [ false, false ];

    assert_merkle_inclusion(root, path, direction_selector, hash([100], 1));
}

pub fn generate_index(direction_selector: [bool; DEPTH]) -> Field {
    let mut index: u32 = 0;
    let depth = DEPTH;

    for i in 0..depth {
        let pos = depth - 1 - i;
        index = index * 2;
        if direction_selector[pos] {
            index = index + 1;
        }
    }
    index as Field
}

#[test]
fn test_generate_index_case1() {
    let directions: [bool; 2] = [true, false];
    let index = generate_index(directions);
    assert(index == 1);
}

#[test]
fn test_generate_index_case2() {
    let directions: [bool; 2] = [false, true];
    let index = generate_index(directions);
    assert(index == 2);
}
