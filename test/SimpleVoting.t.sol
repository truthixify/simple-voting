// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {SimpleVoting} from "../src/SimpleVoting.sol";
import {SimpleVotingScript} from "../script/SimpleVoting.s.sol";

contract SimpleVotingTest is Test {
    // Type Declarations
    enum VoteStatus {
        Active,
        Ended
    }

    SimpleVotingScript public simpleVotingScript;
    SimpleVoting public simpleVoting;

    address public ADMIN = makeAddr("ADMIN");
    address public VOTER_1 = makeAddr("VOTER");
    address public VOTER_2 = makeAddr("VOTER2");
    address public VOTER_3 = makeAddr("VOTER3");
    bytes32[] public candidateNames = [bytes32("Candidate 1"), bytes32("Candidate 2"), bytes32("Candidate 3")];

    // Events
    event Voted(address indexed voter, bytes32 indexed candidateName);

    function setUp() public {
        simpleVotingScript = new SimpleVotingScript();
        simpleVoting = simpleVotingScript.deploySimpleVoting(candidateNames);
    }

    function testSingleVote() public {
        vm.prank(VOTER_1);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_1, "Candidate 1");
        simpleVoting.vote("Candidate 1");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 1"), 1);
    }

    function testMultipleVote() public {
        vm.prank(VOTER_1);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_1, "Candidate 1");
        simpleVoting.vote("Candidate 1");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 1"), 1);

        vm.prank(VOTER_2);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_2, "Candidate 2");
        simpleVoting.vote("Candidate 2");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 2"), 1);

        vm.prank(VOTER_3);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_3, "Candidate 2");
        simpleVoting.vote("Candidate 2");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 2"), 2);
    }

    function testOnlyAdminCanEndVoting() public {
        vm.prank(VOTER_2);
        vm.expectRevert(SimpleVoting.SimpleVoting__OnlyAdmin.selector);
        simpleVoting.endVoting();
    }

    function testRevertWhenVotingHasEnded() public {
        vm.prank(simpleVoting.admin());
        simpleVoting.endVoting();
        vm.prank(VOTER_2);
        vm.expectRevert(SimpleVoting.SimpleVoting__VotingHasEnded.selector);
        simpleVoting.vote("Candidate 2");
    }

    function testRevertWhenAlreadyVoted() public {
        vm.prank(VOTER_2);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_2, "Candidate 2");
        simpleVoting.vote("Candidate 2");

        vm.prank(VOTER_2);
        vm.expectRevert(SimpleVoting.SimpleVoting__AlreadyVoted.selector);
        simpleVoting.vote("Candidate 2");
    }

    function testSingleWinner() public {
        vm.prank(VOTER_1);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_1, "Candidate 1");
        simpleVoting.vote("Candidate 1");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 1"), 1);

        vm.prank(VOTER_2);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_2, "Candidate 2");
        simpleVoting.vote("Candidate 2");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 2"), 1);

        vm.prank(VOTER_3);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_3, "Candidate 2");
        simpleVoting.vote("Candidate 2");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 2"), 2);

        vm.prank(simpleVoting.admin());
        simpleVoting.endVoting();
        bytes32[] memory winners = simpleVoting.getWinner();
        assertEq(winners.length, 1);
        assertEq(winners[0], "Candidate 2");
    }

    function testTie() public {
        vm.prank(VOTER_1);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_1, "Candidate 1");
        simpleVoting.vote("Candidate 1");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 1"), 1);

        vm.prank(VOTER_2);
        vm.expectEmit(true, false, false, false, address(simpleVoting));
        emit Voted(VOTER_2, "Candidate 2");
        simpleVoting.vote("Candidate 2");
        assertEq(simpleVoting.getCandidateVoteCount("Candidate 2"), 1);

        vm.prank(simpleVoting.admin());
        simpleVoting.endVoting();
        bytes32[] memory winners = simpleVoting.getWinner();
        assertEq(winners.length, 2);
        assertEq(winners[0], "Candidate 1");
        assertEq(winners[1], "Candidate 2");
    }
}
