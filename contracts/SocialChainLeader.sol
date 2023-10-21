// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title SocialChainLeader
 * @author Beaker Jin
 * @notice Gather social finance information from chain that this contract deployed
 */

abstract contract SocialChainLeader is Ownable {
    address public immutable socialFi;

    string private _baseUrl;
    address[] public users;
    bytes32 public lastSkewedMerkleRoot; // last skewed merkle root; will be sent to general manager per 1 hour
    uint public epoch; // current epoch
    mapping(address => string) public ipnsUrls; // ipns url of user
    event ChangeAccount(
        uint indexed epoch,
        bytes32 merkleRootOfEpoch,
        bytes changedAccount
    );

    event SendToGeneralManager(uint indexed epoch, bytes32 skewedMerkleRoot);

    constructor(address _socialFi) Ownable(msg.sender) {
        socialFi = _socialFi;
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
    }

    function _checkAccountChange(
        address account
    ) internal virtual returns (bool);

    function addAccount(string memory ipnsUrl) public {
        users.push(msg.sender);
        ipnsUrls[msg.sender] = ipnsUrl;
    }

    function addAccountByOwner(address account) public onlyOwner {
        users.push(account);
    }

    function setBaseUrl(string memory baseUrl) public onlyOwner {
        _baseUrl = baseUrl;
    }

    function getIPFSUrl(address account) public view returns (string memory) {
        return string.concat(_baseUrl, ipnsUrls[account]);
    }

    function deleteAccount(address account) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == account) {
                delete users[i];
                break;
            }
        }
    }
}
