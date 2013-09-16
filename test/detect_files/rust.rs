/*
 * This is the example given by www.rust-lang.org
 */
fn main() {
    let nums = [0, 1, 2, 3];
    let noms = ["Tim", "Eston", "Aaron", "Ben"];

    let mut evens = nums.iter().filter(|&x| x % 2 == 0);

    // This for loop works with rust 0.7 only.
    for evens.advance |&num| {
        do spawn {
            let msg = fmt!("%s says hello from a lightweight thread!",
                           noms[num]);
            println(msg);
        }
    }
}

