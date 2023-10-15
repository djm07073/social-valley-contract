// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {SocialChainLeader} from "./SocialChainLeader.sol";

contract Polygon_SocialChainLeaders is SocialChainLeader {
    constructor(
        uint updateInterval,
        address router,
        address link,
        address _socialFi
    ) SocialChainLeader(updateInterval, router, link, _socialFi) {}
}
