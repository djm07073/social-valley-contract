// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {SocialChainLeader} from "./SocialChainLeader.sol";
import {IPostTechProfile} from "./post_tech/IPostTechProfile.sol";

contract Arbitrum_SocialChainLeader is SocialChainLeader {
    struct AccountState {
        uint256 buyPrice;
        uint256 sellPrice;
        uint256 sharesSupply;
    }
    mapping(address => AccountState) public lastAccountUpdate;

    constructor(
        address router,
        address link,
        address _socialFi,
        address _generalManager
    ) SocialChainLeader(router, link, _socialFi, _generalManager) {}

    function _checkAccountChange(
        address account
    ) internal virtual override returns (bool isChanged) {
        uint256 _buyPrice = IPostTechProfile(socialFi).getBuyPrice(account, 1);
        uint256 _sellPrice = IPostTechProfile(socialFi).getSellPrice(
            account,
            1
        );
        uint256 _sharesSupply = IPostTechProfile(socialFi).sharesSupply(
            account
        );

        isChanged =
            _buyPrice != lastAccountUpdate[account].buyPrice ||
            _sellPrice != lastAccountUpdate[account].sellPrice ||
            _sharesSupply != lastAccountUpdate[account].sharesSupply;

        if (isChanged) {
            lastAccountUpdate[account].buyPrice = _buyPrice;
            lastAccountUpdate[account].sellPrice = _sellPrice;
            lastAccountUpdate[account].sharesSupply = _sharesSupply;
        }
    }
}
