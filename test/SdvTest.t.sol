// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {console} from "forge-std/Script.sol";
import {UsdvToken} from "../src/UsdvToken.sol";
import {SdvNft} from "../src/SdvNft.sol";
import {DeploySdvNft} from "../script/DeploySdvNft.s.sol";
import {WorkflowStatus} from "../src/SimpleVotingSystem.sol";
import {SimpleVotingSystem} from "../src/SimpleVotingSystem.sol";
import {BadStatusFundSession} from "../src/SimpleVotingSystem.sol";

contract SdvTest is Test {

    address USER = makeAddr('USER');
    address USER2 = makeAddr('USER2');
    address FUNDER1 = makeAddr('FUNDER1');
    address VOTER1 = makeAddr('VOTER1');
    address ADMIN_VOTING_SYSTEM = makeAddr("ADMIN_VOTING_SYSTEM");
    address ADMIN_COLLECTION_NFT = makeAddr('admin_NFT');
    address USDV_DEPLOYER = makeAddr('usdv_deployer');
    string USDV_NAME = 'USDV';
    string USDV_SYMBOL = 'USDV';
    uint8 DECIMALS = 6;
    uint INIT_SUPPLY = 500000 * 10 ** DECIMALS; 
    uint MAX_SUPPLY = 1000000 * 10 ** DECIMALS; 
    uint AMOUNT_USD = 1000 * 10 ** DECIMALS;

    uint STARTING_ETH_BALANCE = 10 ether;

    string NFT_NAME = 'Sup De Vinci Nft';
    string NFT_SYMBOL = 'SdvNft';

    string TOKEN_URI = 'https://ipfs.io/ipfs/Qnehyywgwdglh36FGHxfgh788';

    address USDV_TOKEN = 0x2aF3c4E3a6ee455294693B977a2D3DABf419B3B5;
    address SDV_NFT = 0xa727E67fFf460be1D40E638481C034F1836140F6;

    SdvNft sdvNft;

    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    function setUp() public {
        vm.deal(USDV_DEPLOYER, STARTING_ETH_BALANCE);
        // NFT
        DeploySdvNft deploySdvNft = new DeploySdvNft();
        sdvNft = deploySdvNft.run();

    }

    function testDeployerOwnAllTheSupplyAfterDeplyment() public {
        UsdvToken usdvToken;
        vm.startPrank(USDV_DEPLOYER);
        usdvToken = new UsdvToken(USDV_NAME, USDV_SYMBOL, INIT_SUPPLY);
        vm.stopPrank();

        uint balanceOwnerAfter = USDV_DEPLOYER.balance;
        uint balanceOwnerAfterInUsdv = usdvToken.balanceOf(USDV_DEPLOYER);
        console.log('TOTAL SUPPLY : ', usdvToken.totalSupply());
        console.log('BALANCE DEPLOYER : ', balanceOwnerAfter);
        assertEq(balanceOwnerAfterInUsdv, usdvToken.totalSupply());
    }

    function testOnlyDeployerCanMint() public {
        UsdvToken usdvToken;
        vm.startPrank(USDV_DEPLOYER);
        usdvToken = new UsdvToken(USDV_NAME, USDV_SYMBOL, INIT_SUPPLY);
        console.log('TOTAL SUPPLY AVANT : ', usdvToken.totalSupply());
        usdvToken.mint(USER, 1000);
        vm.stopPrank();
        console.log('TOTAL SUPPLY : ', usdvToken.totalSupply());
    }

    // function testCanNotMintAboveTheMaxSupply() public {
    //     UsdvToken usdvToken;
    //     vm.startPrank(USDV_DEPLOYER);
    //     usdvToken = new UsdvToken(USDV_NAME, USDV_SYMBOL, INIT_SUPPLY);
    //     console.log('TOTAL SUPPLY AVANT : ', usdvToken.totalSupply());
    //     vm.expectRevert();
    //     usdvToken.mint(USER, usdvToken.MAX_SUPPLY()*2);
    //     vm.stopPrank();
    //     console.log('TOTAL SUPPLY : ', usdvToken.totalSupply());
    // }

    function testOnlyDeployerCanMint2() public {
        UsdvToken usdvToken;
        vm.startPrank(USDV_DEPLOYER);
        usdvToken = new UsdvToken(USDV_NAME, USDV_SYMBOL, INIT_SUPPLY);
        vm.stopPrank();

        vm.startPrank(USER);
        vm.expectRevert();
        usdvToken.mint(USER2, 100);
        vm.stopPrank();
    }

    /*** TEST NFTs */

    function testNftName() public view {
        string memory expectedName = NFT_NAME;
        string memory actualName = sdvNft.name();
        assertEq(expectedName, actualName);
    }   

    function testNonAdminCannotMintNft() public {
        SdvNft sdvNft_;
        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(USER);
        vm.expectRevert();
        sdvNft_.mintNft(USER2, TOKEN_URI);
        vm.stopPrank();
    }

    function testAdminCanMintNft() public {
        SdvNft sdvNft_;
        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        sdvNft_.mintNft(USER2, TOKEN_URI);
        vm.stopPrank();
    }

    function testUserOwnsNftAfterMint() public {
        SdvNft sdvNft_;
        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        sdvNft_.mintNft(USER2, TOKEN_URI);
        vm.stopPrank();

        assertEq(sdvNft_.balanceOf(USER2), 1);
    }


    //TEST VOTING SYSTEM
    function testVoting() public {
        SimpleVotingSystem votingSystem;
        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, SDV_NFT);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();


        // WorkflowStatus status = votingSystem.getWorkflowStatus(); 
        // assertEq(uint(status), uint(WorkflowStatus.REGISTER_CANDIDATES));
    }

    function testAdminCannotAddCandidateWithWrongWorkflowStatus() public {
        SimpleVotingSystem votingSystem;
        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, SDV_NFT);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        vm.expectRevert();
        votingSystem.addCandidate('John');
        vm.stopPrank();
    }

    function testAdminCanAddCandidateWithCorrectWorkflowStatus() public {
        SimpleVotingSystem votingSystem;
        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, SDV_NFT);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        vm.stopPrank();

        assertEq(votingSystem.getCandidatesCount(), 1);

    }

    function testCandidatesCount() public {
        SimpleVotingSystem votingSystem;
        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, SDV_NFT);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        vm.stopPrank();
        assertEq(votingSystem.getCandidatesCount(), 2);
    }

    function testVoterCannotVoteIfNotGranted() public {
        SimpleVotingSystem votingSystem;
        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, SDV_NFT);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        vm.stopPrank();

        vm.startPrank(VOTER1);
        vm.expectRevert();
        votingSystem.vote(1);
        vm.stopPrank();
    }

    function testVoterCanVoteIfNotGranted2() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        vm.stopPrank();

        vm.startPrank(VOTER1);
        votingSystem.requestGrantForVoting();
        vm.expectRevert();
        votingSystem.vote(1);
        vm.stopPrank();
    }

    function testRequestGrantForVoting() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_.mintNft(VOTER1, TOKEN_URI);
        vm.stopPrank();


        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        vm.stopPrank();

        vm.startPrank(VOTER1);
        votingSystem.requestGrantForVoting();
        vm.stopPrank();

        assertEq(votingSystem.hasRole(VOTER_ROLE, VOTER1), true);
    }

    function testVoterCanVoteIfGranted() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_.mintNft(VOTER1, TOKEN_URI);
        vm.stopPrank();


        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        votingSystem.setWorkflowStatus(WorkflowStatus.VOTE_SESSION);
        vm.stopPrank();

        vm.startPrank(VOTER1);
        votingSystem.requestGrantForVoting();
        votingSystem.vote(1);
        vm.stopPrank();
    }

    function testVoterCannotVoteIfBadStatus() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_.mintNft(VOTER1, TOKEN_URI);
        vm.stopPrank();


        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        vm.stopPrank();

        vm.startPrank(VOTER1);
        votingSystem.requestGrantForVoting();
        vm.expectRevert();
        votingSystem.vote(1);
        vm.stopPrank();
    }

    function testFunderMustBeGranted() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_.mintNft(VOTER1, TOKEN_URI);
        vm.stopPrank();


        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        vm.stopPrank();

        vm.startPrank(FUNDER1);
        vm.expectRevert();
        votingSystem.fundForCampaign(500);
        vm.stopPrank();
    }

    function testFunderCanFundIfWithBadWorkflowStatus() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_.mintNft(VOTER1, TOKEN_URI);
        vm.stopPrank();


        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        vm.stopPrank();


        vm.startPrank(FUNDER1);
        votingSystem.requestGrantForFunding();
        vm.stopPrank();

        vm.startPrank(FUNDER1);
        vm.expectRevert(BadStatusFundSession.selector);
        votingSystem.fundForCampaign(500);
        vm.stopPrank();
    }

    function testFunderCanFundIfWithNotEnoughMoney() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(USDV_TOKEN, address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        votingSystem.setWorkflowStatus(WorkflowStatus.FUND_SESSION);
        vm.stopPrank();


        vm.startPrank(FUNDER1);
        votingSystem.requestGrantForFunding();
        vm.stopPrank();

        vm.startPrank(FUNDER1);
        vm.expectRevert();
        votingSystem.fundForCampaign(500);
        vm.stopPrank();
    }

    function testFunderCannotFundIfNoAllowanceForSmartContract() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;
        UsdvToken usdvToken_;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(USDV_DEPLOYER);
        usdvToken_ = new UsdvToken(USDV_NAME, USDV_SYMBOL, MAX_SUPPLY);
        usdvToken_.mint(FUNDER1, AMOUNT_USD);
        vm.stopPrank();

        console.log('BALANCE FUNDER1 USDV TOKEN');
        console.log(usdvToken_.balanceOf(FUNDER1));

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(address(usdvToken_), address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        votingSystem.setWorkflowStatus(WorkflowStatus.FUND_SESSION);
        vm.stopPrank();


        vm.startPrank(FUNDER1);
        votingSystem.requestGrantForFunding();
        vm.stopPrank();

        vm.startPrank(FUNDER1);
        ///vm.expectRevert();
        votingSystem.fundForCampaign(500);
        vm.stopPrank();
    }

    function testFunderCanFundIfWithMoney() public {
        SimpleVotingSystem votingSystem;
        SdvNft sdvNft_;
        UsdvToken usdvToken_;
        uint amountForDonation = 500;

        vm.startPrank(ADMIN_COLLECTION_NFT);
        sdvNft_ = new SdvNft();
        vm.stopPrank();

        vm.startPrank(USDV_DEPLOYER);
        usdvToken_ = new UsdvToken(USDV_NAME, USDV_SYMBOL, MAX_SUPPLY);
        usdvToken_.mint(FUNDER1, AMOUNT_USD);
        vm.stopPrank();

        console.log('BALANCE FUNDER1 USDV TOKEN');
        console.log(usdvToken_.balanceOf(FUNDER1));

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem = new SimpleVotingSystem(address(usdvToken_), address(sdvNft_));
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.setWorkflowStatus(WorkflowStatus.REGISTER_CANDIDATES);
        vm.stopPrank();

        vm.startPrank(ADMIN_VOTING_SYSTEM);
        votingSystem.addCandidate('John');
        votingSystem.addCandidate('Jane');
        votingSystem.setWorkflowStatus(WorkflowStatus.FUND_SESSION);
        vm.stopPrank();


        vm.startPrank(FUNDER1);
        votingSystem.requestGrantForFunding();
        vm.stopPrank();

        vm.startPrank(FUNDER1);
        usdvToken_.approve(address(votingSystem), amountForDonation);
        vm.stopPrank();

        vm.startPrank(FUNDER1);
        votingSystem.fundForCampaign(500);
        vm.stopPrank();
    }

}