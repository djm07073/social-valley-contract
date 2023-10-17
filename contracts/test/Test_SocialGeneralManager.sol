// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

contract Test_SocialGeneralManager is Ownable, CCIPReceiver {
    /******* Enum *******/
    enum SocialType {
        POST_TECH, //Arbitrum
        FRIEND_TECH, //BASE
        FRIEND3 //BNB
    }

    /******* Storage *******/
    //** 주소에 대해 폴리곤 아이디 맵핑
    // mapping(address => uint) public polygonIds;
    //** 소셜 파이 종류 => 소셜 파이에서 쓰는 계정 => 폴리곤 계정 맵핑
    mapping(SocialType => mapping(address => address))
        public accountRegistration;
    //** 폴리곤 아이디에 대한 ifps metadata uri mapping, 실질적인
    mapping(address => string) public accountMetadataUri;
    mapping(uint64 => address) public whiteList;
    mapping(uint64 => uint32) public chainId;
    string public basicUri = "";

    //** 다른 소셜 체인
    /******* Constructor *******/
    constructor(
        string memory _basicUri,
        address _router
    ) CCIPReceiver(_router) Ownable(msg.sender) {
        basicUri = _basicUri;
    }

    /******* Event *******/
    event GatherInformation(
        bytes32 indexed messageId,
        uint32 chainId,
        bytes skewedMerkleRoot
    );

    // TODO: receive message from social chain leader through CCIP
    // CCIP Receiver를 사용해서 다른 체인 위에 있는 Social Chain Leader가 보낸 정보를 받아온다.
    // 아래와 같이 받아온 merkleRoot를 이벤트 처리한다.

    /******* External *******/
    function ccipReceive(
        Client.Any2EVMMessage calldata message
    ) external override onlyRouter {
        _ccipReceive(message);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        require(
            whiteList[message.sourceChainSelector] ==
                abi.decode(message.sender, (address)),
            "Not in whitelist"
        );
        emit GatherInformation(
            message.messageId,
            chainId[message.sourceChainSelector],
            message.data
        );
    }

    /******* View ******/
    function getUri(
        address valleyAddress
    ) external view returns (string memory) {
        return
            string(
                abi.encodePacked(basicUri, accountMetadataUri[valleyAddress])
            );
    }

    /******* Admin *******/
    function setAccountRegistration(
        SocialType _socialType,
        address socialAddress
    ) external {
        accountRegistration[_socialType][socialAddress] = msg.sender;
    }

    function setAccountMetadataUri(
        address _valleyAddress,
        string memory _metadataUri
    ) external onlyOwner {
        accountMetadataUri[_valleyAddress] = _metadataUri;
    }

    function setWhiteList(
        uint64 chainSelector,
        address chainleader
    ) external onlyOwner {
        whiteList[chainSelector] = chainleader;
    }

    function setChainId(
        uint64 chainSelector,
        uint32 _chainId
    ) external onlyOwner {
        chainId[chainSelector] = _chainId;
    }
}
