// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {MessageSender} from "./MessageSender.sol";

/**
 * @title SocialChainLeader
 * @author Beaker Jin
 * @notice Gather social finance information from chain that this contract deployed
 */

abstract contract SocialChainLeader is MessageSender {
    address public immutable socialFi;
    address public immutable generalManager;
    address[] public users;
    bool isPayedByLink = true;
    bytes32 public lastSkewedMerkleRoot; // last skewed merkle root; will be sent to general manager per 1 hour
    uint public epoch; // current epoch

    event ChangeAccount(
        uint indexed epoch,
        bytes32 merkleRootOfEpoch,
        bytes changedAccount
    );

    event SendToGeneralManager(uint indexed epoch, bytes32 skewedMerkleRoot);

    constructor(
        address router,
        address link,
        address _socialFi,
        address _generalManager
    ) MessageSender(router, link) {
        socialFi = _socialFi;
        generalManager = _generalManager;
    }

    //        Root - epoch N (0,1,2,3, ...)
    //        / \
    //      H1    H2
    //     / \    / \
    //   H3  H4  H5  H6
    //  / \ / \ / \ / \
    // A1 A2 A3 A4 A5 A6
    function createBalancedMerkleRoot(
        address[] memory changedAccounts
    ) internal view virtual returns (bytes32) {
        uint256 numLeaves = changedAccounts.length;
        if (numLeaves == 0) {
            return bytes32(0);
        } else {
            bytes32[] memory leaves = new bytes32[](numLeaves);

            for (uint256 i = 0; i < numLeaves; i++) {
                // Convert the address to bytes32 and use it as a leaf in the Merkle tree
                leaves[i] = bytes32(uint256(uint160(changedAccounts[i])));
            }

            return _calculateMerkleRoot(leaves);
        }
    }

    function _calculateMerkleRoot(
        bytes32[] memory elements
    ) internal pure returns (bytes32) {
        require(
            elements.length > 0,
            "Merkle tree requires at least one element."
        );

        while (elements.length > 1) {
            bytes32[] memory parentLevel = new bytes32[](elements.length / 2);

            for (uint256 i = 0; i < elements.length / 2; i++) {
                // Combine pairs of elements to create parents
                parentLevel[i] = keccak256(
                    abi.encodePacked(elements[i * 2], elements[i * 2 + 1])
                );
            }

            elements = parentLevel;
        }

        return elements[0];
    }

    /**
     * @notice Check if the state of account has changed
     * this function only emit event when the state of account has changed,
     * then store root of skewed merkle tree
     * @dev This function will be called by Time-based trigger per 15 minutes
     * @return balancedMerkleRoot The merkle root of the state of all accounts that have changed in the last 30 minutes
     */
    //     Root
    //     / \
    //   H1 merkleRoot of epoch N + 12 ~ N + 15
    //      / \
    //     H2 merkleRoot of epoch N + 8 ~ N + 11
    //        /  \
    //      H3   merkleRoot of epoch N + 4 ~ N + 7
    //     /  \
    //    /    \
    //  last  merkleRoot of epoch N ~ N + 3

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
        balancedMerkleRoot = createBalancedMerkleRoot(changedAccount);
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
        if (epoch % 4 == 0) {
            sendToGeneralManager();
        }
    }

    function _checkAccountChange(
        address account
    ) internal virtual returns (bool);

    /**
     * @notice Send the merkle root to general manager
     * @dev This function will be called by Time-based trigger per 1 hour
     */
    function sendToGeneralManager() internal returns (bytes32 messageId) {
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

        emit SendToGeneralManager(epoch, lastSkewedMerkleRoot);
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

    function setPayedByLink(bool _isPayedByLink) public onlyOwner {
        isPayedByLink = _isPayedByLink;
    }
}
