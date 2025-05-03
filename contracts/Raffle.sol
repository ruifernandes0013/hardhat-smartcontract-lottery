// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

error Raffle_NotEnoughValue();
error Raffle_TransferFailed();
error Raffle_NotOpen();
error Raffle_VRFRequestFailed();
error Raffle_UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 raffleState);

/**
 * @title A sample Raffle Contract
 * @author Rui Fernandes
 * @notice This contract is for creating a sample raffle contract
 * @dev This implements the Chainlink VRF Version 2.5
 */
contract Raffle is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {
  //enum
  enum RaffleState {
    OPEN,
    CALCULATING
  }
  //storage
  address payable[] private s_players;
  address payable private s_recent_winner;
  RaffleState private s_raffleState;
  uint256 private s_lastTimeStamp;

  //immutable
  uint256 private immutable i_subscriptionId;
  bytes32 private immutable i_keyHash;

  //constant
  uint8 private constant REQUEST_CONFIRMATIONS = 3;
  uint8 private constant INTERVAL = 10;
  uint8 private constant NUM_WORDS = 1;
  uint32 private constant CALL_BACK_GAS_LIMIT = 100000;
  uint64 private constant ENTRANCE_FEE = 0.01 ether;

  //events
  event RaffleEnter(address indexed player);
  event RequestedRaffleWinner(uint256 indexed requestId);
  event WinnerPicked(address indexed winner);

  constructor(
    address vrfAddress,
    uint256 subscriptionId,
    bytes32 keyHash
  ) VRFConsumerBaseV2Plus(vrfAddress) {
    i_subscriptionId = subscriptionId;
    i_keyHash = keyHash;
    s_raffleState = RaffleState.OPEN;
    s_lastTimeStamp = block.timestamp;
  }

  function enterRaffle() public payable {
    if (msg.value < ENTRANCE_FEE) {
      revert Raffle_NotEnoughValue();
    }

    if (s_raffleState != RaffleState.OPEN) {
      revert Raffle_NotOpen();
    }

    s_players.push(payable(msg.sender));
    emit RaffleEnter(msg.sender);
  }

  /**
   * @dev This is the function that the Chainlink Keeper nodes call
   * they look for `upkeepNeeded` to return True.
   * the following should be true for this to return true:
   * 1. The time interval has passed between raffle runs.
   * 2. The lottery is open.
   * 3. The contract has ETH.
   * 4. Implicity, your subscription is funded with LINK.
   */
  function checkUpkeep(
    bytes calldata /* checkData */
  ) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
    bool isOpen = s_raffleState == RaffleState.OPEN;
    bool timePassed = ((block.timestamp - s_lastTimeStamp) > INTERVAL);
    bool hasPlayers = (s_players.length > 0);
    bool hasMoney = address(this).balance > 0;

    upkeepNeeded = isOpen && hasPlayers && hasMoney && timePassed;
    return (upkeepNeeded, "0x0");
  }

  /**
   * @dev Once `checkUpkeep` is returning `true`, this function is called
   * and it kicks off a Chainlink VRF call to get a random winner.
   */
  function performUpkeep(bytes calldata /* performData */) external override {
    bool upkeepNeeded = _checkUpkeep();
    if (!upkeepNeeded) {
      revert Raffle_UpkeepNotNeeded(
        address(this).balance,
        s_players.length,
        uint256(s_raffleState)
      );
    }

    try
      s_vrfCoordinator.requestRandomWords(
        VRFV2PlusClient.RandomWordsRequest({
          keyHash: i_keyHash,
          subId: i_subscriptionId,
          requestConfirmations: REQUEST_CONFIRMATIONS,
          callbackGasLimit: CALL_BACK_GAS_LIMIT,
          numWords: NUM_WORDS,
          extraArgs: VRFV2PlusClient._argsToBytes(
            VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
          )
        })
      )
    returns (uint256 requestId) {
      s_raffleState = RaffleState.CALCULATING;
      emit RequestedRaffleWinner(requestId);
    } catch {
      revert Raffle_VRFRequestFailed();
    }
  }

  /**
   * @dev This is the function that Chainlink VRF node
   * calls to send the money to the random winner.
   */
  function fulfillRandomWords(
    uint256 /* _requestId */,
    uint256[] calldata _randomWords
  ) internal override {
    uint256 winnerIndex = _randomWords[0] % s_players.length;

    s_recent_winner = s_players[winnerIndex];
    s_raffleState = RaffleState.OPEN;
    s_players = new address payable[](0);
    s_lastTimeStamp = block.timestamp;

    (bool success, ) = s_recent_winner.call{value: address(this).balance}("");
    if (!success) {
      revert Raffle_TransferFailed();
    }

    emit WinnerPicked(s_recent_winner);
  }

  function _checkUpkeep() private view returns (bool upkeepNeeded) {
    bool isOpen = s_raffleState == RaffleState.OPEN;
    bool timePassed = ((block.timestamp - s_lastTimeStamp) > INTERVAL);
    bool hasPlayers = (s_players.length > 0);
    bool hasMoney = address(this).balance > 0;

    upkeepNeeded = isOpen && hasPlayers && hasMoney && timePassed;
  }

  function getEntranceFee() external pure returns (uint256) {
    return ENTRANCE_FEE;
  }

  function getPlayer(uint256 index) external view returns (address) {
    return s_players[index];
  }

  function getRecentWinner() external view returns (address) {
    return s_recent_winner;
  }

  function getRaffleState() external view returns (RaffleState) {
    return s_raffleState;
  }

  function getLastTimeStamp() external view returns (uint256) {
    return s_lastTimeStamp;
  }

  function getInterval() external pure returns (uint256) {
    return INTERVAL;
  }

  function getCallBackGasLimit() external pure returns (uint256) {
    return CALL_BACK_GAS_LIMIT;
  }

  function getRequestConfirmations() external pure returns (uint256) {
    return REQUEST_CONFIRMATIONS;
  }

  function getNumWords() external pure returns (uint256) {
    return NUM_WORDS;
  }
}
