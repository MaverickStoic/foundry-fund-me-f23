// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../../src/FundMe.sol';
import {DeployFundMe} from '../../script/DeployFundMe.s.sol/';
contract FundMeTest is Test{
	FundMe fundMe;
	address USER = makeAddr("user");
	uint constant SEND_VALUE = 0.1 ether;
	uint constant STARTING_BALANCE = 10 ether;
	uint constant GAS_PRICE = 1;

	function setUp() external{
		//fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
		DeployFundMe deployFundMe = new DeployFundMe();
		fundMe = deployFundMe.run();
		vm.deal(USER, STARTING_BALANCE);
	}

	function testMinDollarIsFive() public{
		console.log(fundMe.MINIMUM_USD());
		assertEq(fundMe.MINIMUM_USD(), 5e18);
	}

	function testOwnerIsMsgSender() public{
		assertEq(fundMe.i_owner(), msg.sender);
	}

	function testPriceFeedVersionIsAcurate() public{
		uint version = fundMe.getVersion();
		assertEq(version, 4);
	}

	function testFundFailsWithoutEnoughETH() public{
		vm.expectRevert();
		fundMe.fund();
	}

	function testFundUpdatesDataStructure() public funded(){

		uint amountFunded = fundMe.getAddressToAmountFunded(USER);
		assertEq(amountFunded, SEND_VALUE);
	}
	function testAddsFunderToArrayOfFunders() public funded(){

		address funder = fundMe.getFunder(0);
		assertEq(funder, USER);
	}

	modifier funded(){
		vm.prank(USER);
		fundMe.fund{value: SEND_VALUE}();
		_;
	} 
	function testOnlyOwnerCanWithdraw() public funded(){
		vm.expectRevert();
		vm.prank(USER);
		fundMe.withdraw();
	}

	function testWithdrawWithASingleFunder() public funded(){
		uint startingOwnerBalance = fundMe.getOwner().balance;
		uint startingFundMeBalance = address(fundMe).balance;

		uint gasStart = gasleft();
		vm.txGasPrice(GAS_PRICE);
		vm.prank(fundMe.getOwner());
		fundMe.withdraw();

		uint gasEnd = gasleft();
		uint gasUsed = (gasStart - gasEnd) * tx.gasprice;
		console.log(gasUsed);

		uint endingOwnerBalance = fundMe.getOwner().balance;
		uint endingFundMeBalance = address(fundMe).balance;
		assertEq(endingFundMeBalance, 0);
		assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
	}

	function testWithdrawFormMultipleFunders() public funded(){
		uint160 numberOfFUnders = 10;
		uint160 startingFunderIndex = 1;
		for(uint160 i=  startingFunderIndex; i < numberOfFUnders; i++){
			hoax(address(i), SEND_VALUE);
			fundMe.fund{value: SEND_VALUE}();
		}
		uint startingOwnerBalance = fundMe.getOwner().balance;
		uint startingFundMeBalance = address(fundMe).balance;

		vm.startPrank(fundMe.getOwner());
		fundMe.withdraw();
		vm.stopPrank();

		assert(address(fundMe).balance == 0);
		assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);

	}
	function testWithdrawFormMultipleFundersCheaper() public funded(){
		uint160 numberOfFUnders = 10;
		uint160 startingFunderIndex = 1;
		for(uint160 i=  startingFunderIndex; i < numberOfFUnders; i++){
			hoax(address(i), SEND_VALUE);
			fundMe.fund{value: SEND_VALUE}();
		}
		uint startingOwnerBalance = fundMe.getOwner().balance;
		uint startingFundMeBalance = address(fundMe).balance;

		vm.startPrank(fundMe.getOwner());
		fundMe.cheaperWithdraw();
		vm.stopPrank();

		assert(address(fundMe).balance == 0);
		assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);

	}
}