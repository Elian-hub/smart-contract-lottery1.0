//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/contracts/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscription} from "script/Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        // local -> deploy mocks, get local config
        // sepolia -> get sepolia config
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            //create subscription
            CreateSubscription createSub = new CreateSubscription();
            (uint256 subId, address coordinator) = createSub.createSubscription(config.vrfCoordinator);
            config.subscriptionId = uint64(subId);
            config.vrfCoordinator = coordinator;
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.vrfCoordinator,
            config.keyHash,
            config.subscriptionId,
            config.callbackGasLimit,
            config.interval,
            config.entranceFee
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}
