// SPDX-License-Identifier: MIT
import {Script, console} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/MockV3Aggregator.sol';
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from '../src/FundMe.sol';
pragma solidity ^0.8.19;

contract FundFundMe is Script{
	uint constant SEND_VALUE = 0.1 ether;


	function fundFundMe(address mostRecentlyDeployed) public {
		vm.startBroadcast();
		FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
		vm.stopBroadcast();
		console.log("funded FundMe with %$", SEND_VALUE);
	}


	function run() external{
		address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
		vm.startBroadcast();
		fundFundMe(mostRecentlyDeployed);
		vm.stopBroadcast();
	}
}

contract WithdrawFundMe is Script{
	uint constant SEND_VALUE = 0.01 ether;

	function withdrawFundMe(address mostRecentlyDeployed) public {
		vm.startBroadcast();
		FundMe(payable(mostRecentlyDeployed)).withdraw();
		vm.stopBroadcast();

	}
	function run() external{
		
		address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
		
		withdrawFundMe(mostRecentlyDeployed);
		
	}
}