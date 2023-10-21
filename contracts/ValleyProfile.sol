// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract ValleyProfile {
    mapping(address => string) public getSocialAccountInfo;
    mapping(address => string) public getReputation;

    function makeProfile(string memory ipns1, string memory ipns2) public {
        getSocialAccountInfo[msg.sender] = ipns1;
        getReputation[msg.sender] = ipns2;
    }
}
