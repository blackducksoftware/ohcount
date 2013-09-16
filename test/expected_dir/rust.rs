rust	comment	/*
rust	comment	 * This is the example given by www.rust-lang.org
rust	comment	 */
rust	code	fn main() {
rust	code	    let nums = [0, 1, 2, 3];
rust	code	    let noms = ["Tim", "Eston", "Aaron", "Ben"];
rust	blank	
rust	code	    let mut evens = nums.iter().filter(|&x| x % 2 == 0);
rust	blank	
rust	comment	    // This for loop works with rust 0.7 only.
rust	code	    for evens.advance |&num| {
rust	code	        do spawn {
rust	code	            let msg = fmt!("%s says hello from a lightweight thread!",
rust	code	                           noms[num]);
rust	code	            println(msg);
rust	code	        }
rust	code	    }
rust	code	}
rust	blank	
