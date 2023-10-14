// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

contract SocialGeneralManager is Ownable, CCIPReceiver {
    /******* Enum *******/
    enum SocialType {
        POST_TECH, //Arbitrum
        LENS, //Polygon
        STAR_ARENA //Avalanche
    }
    /******* Storage *******/
    //** 주소에 대해 폴리곤 아이디 맵핑
    mapping(address => uint) public polygonIds;
    //** 폴리곤 아이디에 대한 주소 맵핑
    mapping(uint => mapping(SocialType => bool)) public accountRegistration;
    //** 폴리곤 아이디에 대한 ifps metadata uri mapping, 실질적인
    mapping(uint => string) public accountMetadataUri;
    string public immutable basicUri;

    //** 다른 소셜 체인
    /******* Constructor *******/
    constructor(string memory _basicUri) Ownable(msg.sender) {
        basicUri = _basicUri;
    }

    /******* Event *******/
    event GatherInformation(
        uint updateBlockTimestamp,
        uint chainId,
        uint merkleRoot
    );

    // TODO: receive message from social chain leader through CCIP
    // CCIP Receiver를 사용해서 다른 체인 위에 있는 Social Chain Leader가 보낸 정보를 받아온다.
    // 아래와 같이 받아온 merkleRoot를 이벤트 처리한다.

    /******* External *******/
    function receiveInformation(
        Client.MessageFromLeader memory messageFromLeader
    ) external onlyOwner {
        emit GatherInformation(
            block.timestamp,
            messageFromLeader.chainId,
            messageFromLeader.merkleRoot
        );
    }

    /******* View ******/
    function getUri(uint _polygonId) external view returns (string memory) {
        return
            string(abi.encodePacked(basicUri, accountMetadataUri[_polygonId]));
    }

    /******* Admin *******/
    function setPolygonId(
        address _address,
        uint _polygonId
    ) external onlyOwner {
        polygonIds[_address] = _polygonId;
    }

    function setAccountRegistration(
        uint _polygonId,
        SocialType _socialType,
        bool _isRegistered
    ) external onlyOwner {
        accountRegistration[_polygonId][_socialType] = _isRegistered;
    }

    function setAccountMetadataUri(
        uint _polygonId,
        string memory _metadataUri
    ) external onlyOwner {
        accountMetadataUri[_polygonId] = _metadataUri;
    }
}
