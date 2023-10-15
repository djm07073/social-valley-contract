// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {MessageSender} from "./MessageSender.sol";

/**
 * @title SocialChainLeader
 * @author Beaker Jin
 * @notice Gather social finance information from chain that this contract deployed
 */
abstract contract SocialChainLeader is MessageSender {
    address public immutable socialFi;
    uint public immutable interval;
    address public immutable generalManager;
    address[] public users;
    bytes32 public lastSkewedMerkleRoot; // last skewed merkle root; will be sent to general manager per 1 hour
    uint public epoch; // current epoch

    event ChangeAccount(
        uint indexed epoch,
        bytes32 merkleRootOfEpoch,
        bytes changedAccount
    );

    constructor(
        uint updateInterval,
        address router,
        address link,
        address _socialFi,
        address _generalManager
    ) MessageSender(router, link) {
        interval = updateInterval;
        socialFi = _socialFi;
        generalManager = _generalManager;
    }

    // skewed merkle tree
    function createSkewedMerkleRoot(
        address[] memory changedAccounts
    ) internal view virtual returns (bytes32) {}

    /**
     * @notice Check if the state of account has changed
     * this function only emit event when the state of account has changed,
     * then store root of skewed merkle tree
     * @dev This function will be called by Time-based trigger per 15 minutes
     * @return balancedMerkleRoot The merkle root of the state of all accounts that have changed in the last 30 minutes
     */
    function createSkewedMerkleRootOfChangeAccount()
        external
        returns (bytes32 balancedMerkleRoot)
    {
        address[] memory changedAccount = new address[](users.length);
        uint length = 0;
        // 1. make if the state of registered account has changed
        for (uint i = 0; i < users.length; i++) {
            if (_checkAccountChange(users[i])) {
                changedAccount[length] = users[i];
                length++;
            }
        }
        // 2. create skewed merkle root & balanced merkle root of present epoch
        balancedMerkleRoot = createSkewedMerkleRoot(changedAccount);
        lastSkewedMerkleRoot = keccak256(
            abi.encodePacked(lastSkewedMerkleRoot, balancedMerkleRoot)
        );
        // 3. Emit event ChangeAccount & increase epoch
        emit ChangeAccount(
            epoch,
            balancedMerkleRoot,
            abi.encodePacked(changedAccount)
        );
        epoch++;
    }

    function _checkAccountChange(
        address account
    ) internal view virtual returns (bool) {}

    /**
     * @notice Send the merkle root to general manager
     * @dev This function will be called by Time-based trigger per 1 hour
     */
    function sendToGeneralManager(
        bool isPayedByLink
    ) external returns (bytes32 messageId) {
        if (isPayedByLink) {
            messageId = sendMessagePayLINK(
                generalManager,
                lastSkewedMerkleRoot
            );
        } else {
            messageId = sendMessagePayNative(
                generalManager,
                lastSkewedMerkleRoot
            );
        }
    }

    function addAccount(address newAccount) public onlyOwner {
        users.push(newAccount);
    }

    function deleteAccount(address account) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == account) {
                delete users[i];
                break;
            }
        }
    }

    function checkChangeSocial() public view virtual {}
}
