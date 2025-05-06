// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SimpleVoting} from "../src/SimpleVoting.sol";

contract SimpleVotingScript is Script {
    SimpleVoting public simpleVoting;

    function setUp() public {}

    function run() public {}

    function deploySimpleVoting(bytes32[] memory candidateNames) public returns (SimpleVoting) {
        vm.startBroadcast();

        simpleVoting = new SimpleVoting(candidateNames);

        vm.stopBroadcast();

        return simpleVoting;
    }
}
