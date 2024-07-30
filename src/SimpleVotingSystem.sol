// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

enum  WorkflowStatus {
    INIT,
    REGISTER_CANDIDATES,
    FUND_SESSION,
    VOTE_SESSION,
    VOTE_COUNT
}

error BadStatusRegisterCandidatesError();

error BadStatusFundSession();

error BadStatusVoteSession();

error NotEnoughAmountForFunding();

contract SimpleVotingSystem is Ownable, AccessControl {

    IERC20 private cryptoAccepted;
    IERC721 private nftAccepted;

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;
    uint[] private candidateIds;

    WorkflowStatus private workflowStatus;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");
    bytes32 public constant FUNDER_ROLE = keccak256("FUNDER_ROLE");
    
    uint public MIN_AMOUNT_FOR_FUNDING = 100;

    constructor(address addressCryptoAccepted, address addressNftAccepted) Ownable(msg.sender) {
        cryptoAccepted = IERC20(addressCryptoAccepted);
        nftAccepted    = IERC721(addressNftAccepted);
        _grantRole(ADMIN_ROLE, msg.sender);       
    }

    function setWorkflowStatus(WorkflowStatus _num) public onlyRole(ADMIN_ROLE) {
        workflowStatus = WorkflowStatus(_num);
       } 
     
    function addCandidate(string memory _name) public onlyRole(ADMIN_ROLE) {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        if (workflowStatus != WorkflowStatus.REGISTER_CANDIDATES) revert BadStatusRegisterCandidatesError();
        uint candidateId = candidateIds.length + 1;
        candidates[candidateId] = Candidate(candidateId, _name, 0);
        candidateIds.push(candidateId);
    }

    function vote(uint _candidateId) public onlyRole(VOTER_ROLE){
        require(!voters[msg.sender], "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
        if (workflowStatus != WorkflowStatus.VOTE_SESSION) revert BadStatusVoteSession();
        voters[msg.sender] = true;
        candidates[_candidateId].voteCount += 1;
    }

    function getTotalVotes(uint _candidateId) public view returns (uint) {
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
        return candidates[_candidateId].voteCount;
    }

    function fundForCampaign(uint256 amount) public onlyRole(FUNDER_ROLE) {
        if (workflowStatus != WorkflowStatus.FUND_SESSION) revert BadStatusFundSession();
        uint balanceOfFunder = cryptoAccepted.balanceOf(msg.sender);
        if (balanceOfFunder < MIN_AMOUNT_FOR_FUNDING) revert NotEnoughAmountForFunding();
        cryptoAccepted.transferFrom(msg.sender, address(this), amount);
    }

    function requestGrantForFunding() public {
        _grantRole(FUNDER_ROLE, msg.sender);
    }

    function requestGrantForVoting() public {
        uint balanceOfNfts = nftAccepted.balanceOf(msg.sender);
        if (balanceOfNfts >= 1) {
            _grantRole(VOTER_ROLE, msg.sender);
        }
    }

    function getCandidatesCount() public view returns (uint) {
        return candidateIds.length;
    }

    // Optional: Function to get candidate details by ID
    function getCandidate(uint _candidateId) public view returns (Candidate memory) {
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
        return candidates[_candidateId];
    }

    function getWorkflowStatus() public view returns (WorkflowStatus) {
        return workflowStatus;
    }

    function getCryptoAccepted() public view returns (IERC20) {
        return cryptoAccepted;
    }

    function getNftAccepted() public view returns (IERC721) {
        return nftAccepted;
    }
}
