// // Layout of Contract:
// // version
// // imports
// // errors
// // interfaces, libraries, contracts
// // Type declarations
// // State variables
// // Events
// // Modifiers
// // Functions

// // Layout of Functions:
// // constructor
// // receive function (if exists)
// // fallback function (if exists)
// // external
// // public
// // internal
// // private
// // view & pure functions
// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.18;
// import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

// /**
//  * @title A sample Raffle Contract
//  * @author Elian
//  * @notice This contract is for creating a sample raffle
//  * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
//  */

// contract Raffle {
//     /* errors*/
//     error Raffle__NotEnoughEthSent();

//     uint256 private immutable i_entranceFee;
//     // @dev Duration of the lottery in seconds
//     uint256 private immutable i_interval;
//     address payable[] private s_players;
//     uint256 private s_lastTimeStamp;
//     /* Events */

//     event RaffleEntered(address indexed player);

//     constructor(uint256 entranceFee, uint256 interval) {
//         i_entranceFee = entranceFee;
//         i_interval = interval;
//         s_lastTimeStamp = block.timestamp;
//     }

//     function enterRaffle() public payable {
//         // require(msg.value >= i_entranceFee, "Not enough ETH sent!");
//         if (msg.value < i_entranceFee) {
//             revert Raffle__NotEnoughEthSent();
//         }
//         s_players.push(payable(msg.sender));
//         emit RaffleEntered(msg.sender);
//     }

//     function pickWinner() external view {
//         if (block.timestamp - s_lastTimeStamp < i_interval) {
//             revert();
//         }
//         requestId = s_vrfCoordinator.requestRandomWords(
//             VRFV2PlusClient.RandomWordsRequest({
//                 keyHash: s_keyHash,
//                 subId: s_subscriptionId,
//                 requestConfirmations: requestConfirmations,
//                 callbackGasLimit: callbackGasLimit,
//                 numWords: numWords,
//                 extraArgs: VRFV2PlusClient._argsToBytes(
//                     // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
//                     VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
//                 )
//             })
//         );
//     }

//     /**
//      * Getter Function
//      */
//     function getEntranceFee() external view returns (uint256) {
//         return i_entranceFee;
//     }
// }

pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract Raffle is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    address payable[] private s_players;

    event RaffleEntered(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);

    constructor(
        address vrfCoordinator,
        bytes32 keyHash,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 entranceFee,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() public payable {
        require(msg.value >= i_entranceFee, "Not enough ETH sent!");
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        require((block.timestamp - s_lastTimeStamp) >= i_interval, "Interval not met");
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash, i_subscriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // Implement winner selection logic here
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
