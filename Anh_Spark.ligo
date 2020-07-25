//ID number of the coin
type sparkID is nat;

// @each coin is a record type
type spark is record [
    owner : address;
]

//map the address of the acount to the spark ID
type sparks is map(sparkID, spark);

//store the number of sparks left
type storageType is record [
    supply : 10000
    sparks : sparks;
    contractOwner : address;
];

type actionTransfer is record [
  sparkToTransfer : sparkID;
  destination : address;
]

type actionBurn is record [
  sparkToBurnId : sparkID;
]

type deflating is record [
  sparkID : sparkID;
]

type action is
| Transfer of actionTransfer
| Burn of actionBurn

// Transfers the ownership of an spark by replacing the owner address.
// @param sparkToTransfer - ID of the spark
// @param destination - Address of the recipient
function transfer(const action : actionTransfer ; const s : storageType) : (list(operation) * storageType) is
  block { 
    const spark : spark = get_force(action.sparkToTransfer, s.sparks);
    const owner: address = spark.owner;
    // check for permission
    if source =/= owner then failwith("You do not have permission to transfer this asset.")
    else skip;
    // change owner's address
    const sparks : sparks = s.sparks;
    spark.owner := action.destination; 
    sparks[action.sparkToTransfer] := spark;
    s.sparks := sparks;
   } with ((nil: list(operation)) , s)

// Burns an spark by removing its entry from the contract.
// @param sparkToBurnId - ID of the spark
function burn(const action : actionBurn ; const s : storageType) : (list(operation) * storageType) is
  block { 
    const spark : spark = get_force(action.sparkToBurnId, s.sparks);
    // check for permission
    if source =/= spark.owner then failwith("You can not burn this coin")
    else skip;
    // remove spark
    const sparks : sparks = s.sparks;
    remove action.sparkToBurnId from map sparks;
    s.sparks := sparks;
   } with ((nil: list(operation)) , s)

// @param Any of the action types defined above.
function main(const action : action; const s : storageType) : (list(operation) * storageType) is 
 block {skip} with 
 case action of
 | Transfer (tx) -> transfer (tx, s)
 | Burn (bn) -> burn (bn, s)
 | Deflate (en) -> deflate (en, s)
end