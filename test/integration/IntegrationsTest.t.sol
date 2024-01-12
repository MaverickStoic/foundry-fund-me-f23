// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../../src/FundMe.sol';
import {DeployFundMe} from '../../script/DeployFundMe.s.sol/';
import {FundFundMe, WithdrawFundMe} from '../../script/Interactions.s.sol';
contract InteractionsTest is Test{
	FundMe fundMe;
	address USER = makeAddr("user");
	
	uint constant STARTING_BALANCE = 100 ether;
	uint constant SEND_VALUE = 0.1 ether;
	uint constant GAS_PRICE = 1;

	function setUp() external{
		
		DeployFundMe deployFundMe = new DeployFundMe();
		fundMe = deployFundMe.run();
		
		vm.deal(USER, STARTING_BALANCE);
		

	}


	function testUserCanFundInteractions() public{
		FundFundMe fundFundMe = new FundFundMe();
		//vm.prank(USER);
		//vm.deal(USER, 1e18);
		//vm.stopPrank();
		fundFundMe.fundFundMe(address(fundMe));

		console.log(address(fundMe));
		console.log(msg.sender);

		WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
		withdrawFundMe.withdrawFundMe(address(fundMe));

		//address funder = fundMe.getFunder(0);
		//assertEq(funder, USER);
		assert(address(fundMe).balance == 0);
	}
}