//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRoughWaters.sol";

contract RoughWaters is Ownable, IRoughWaters {

  enum SequenceStatus {
    NOT_DONE,
    DONE,
    SKIPPED
  }

  mapping(address => string) private _names;
  mapping(address => string) private _pronouns;
  mapping(address => mapping(uint256 => uint256)) private _affinities;
  mapping(address => mapping(uint256 => uint256)) private _stats;
  mapping(address => mapping(uint256 => SequenceStatus)) private _sequenceStatuses;
  mapping(address => uint256) private _sequenceCache;
  mapping(address => mapping(uint256 => uint256)) private _choicesMade;
  mapping(uint256 => bool) private _deletedSequences;
  mapping(uint256 => uint256) private _choiceSequence;
  mapping(uint256 => uint256) private _choiceOptions;
  uint256 private _sequenceCount;
  uint256 private _choiceCount;
  address Coins;
  address Items;
  address Collection;

  constructor() {
    // TODO: deploy Coins, Items and Collection
  }

  function updateScenario(uint256 sequenceCount, uint256 choiceCount) public onlyOwner {
    _sequenceCount += sequenceCount;
    _choiceCount += choiceCount;
    emit ScenarioUpdated(_sequenceCount, _choiceCount);
  }

  function setChoicesSequences(uint256[] calldata choices, uint256[] calldata sequences) public onlyOwner {
    require(choices.length == sequences.length, "Bad request");
    for (uint256 i = 0; i < choices.length; i++) {
      require(choices[i] < _choiceCount, "That choice does not exist");
      require(_choiceSequence[choices[i]] == 0, "That choice already belongs to a sequence");
      require(sequences[i] != 0, "Cannot unset a choice's sequence");
      _choiceSequence[choices[i]] = sequences[i];
      emit ChoiceAssigned(choices[i], sequences[i]);
    }
  }

  function setChoicesOptions(uint256[] calldata choices, uint256[] calldata options) public onlyOwner {
    require(choices.length == options.length, "Bad request");
    for (uint256 i = 0; i < choices.length; i++) {
      require(choices[i] < _choiceCount, "That choice does not exist");
      require(_choiceOptions[choices[i]] == 0, "That choice already has its options");
      _choiceSequence[choices[i]] = options[i];
      emit ChoiceOptionsAssigned(choices[i], options[i]);
    }
  }

  function updateChoicesSequences(uint256[] calldata choices, uint256[] calldata sequences) public onlyOwner {
    require(choices.length == sequences.length, "Bad request");
    for (uint256 i = 0; i < choices.length; i++) {
      require(_choiceSequence[choices[i]] > 0, "That choice was not assigned yet");
      _choiceSequence[choices[i]] = sequences[i];
    }
  }

  function updateChoicesOptions(uint256[] calldata choices, uint256[] calldata options) public onlyOwner {
    require(choices.length == options.length, "Bad request");
    for (uint256 i = 0; i < choices.length; i++) {
      require(_choiceSequence[choices[i]] > 0, "That choice has no options yet");
      _choiceSequence[choices[i]] = options[i];
    }
  }

  function deleteSequence(uint256 sequenceId) public onlyOwner {
    require(sequenceId <= _sequenceCount, "Inexisting sequence");
    _deletedSequences[sequenceId] = true;
    emit SequenceDeleted(sequenceId);
  }

  function finishSequence(uint256 sequenceId) public {
    require(_sequenceCount > 0, "Game has not started");
    require(sequenceId > 0 && sequenceId <= _sequenceCount, "Inexisting sequence");
    require(_deletedSequences[sequenceId] == false, "Deleted sequence");
    require(_sequenceStatuses[msg.sender][sequenceId] == SequenceStatus.NOT_DONE, "Sequence already processed");
    for (uint256 i = 1; i < sequenceId; i++) {
      require(
        _deletedSequences[i] || _sequenceStatuses[msg.sender][i] != SequenceStatus.NOT_DONE,
        "You're not there yet"
      );
    }
    _sequenceStatuses[msg.sender][sequenceId] = SequenceStatus.DONE;
    _sequenceCache[msg.sender] = sequenceId;
    emit SequenceFinished(msg.sender, sequenceId);
  }

  function skipSequence(uint256 sequenceId) public {
    require(_sequenceCount > 0, "Game has not started");
    require(sequenceId > 0 && sequenceId <= _sequenceCount, "Inexisting sequence");
    require(_deletedSequences[sequenceId] == false, "Deleted sequence");
    require(_sequenceStatuses[msg.sender][sequenceId] == SequenceStatus.NOT_DONE, "Sequence already processed");
    for (uint256 i = 1; i < sequenceId; i++) {
      require(
        _deletedSequences[i] || _sequenceStatuses[msg.sender][i] != SequenceStatus.NOT_DONE,
        "You're not there yet"
      );
    }
    _sequenceStatuses[msg.sender][sequenceId] = SequenceStatus.SKIPPED;
    _sequenceCache[msg.sender] = sequenceId;
    emit SequenceSkipped(msg.sender, sequenceId);
  }

  function makeChoice(uint256 choiceId, uint256 choiceResponse) public {
    require(choiceId < _choiceCount, "Inexisting choice");
    require(_choiceSequence[choiceId] != 0, "That choice was not initialized");
    require(getNextSequence() == _choiceSequence[choiceId], "You're not there yet");
    require(choiceResponse < _choiceOptions[choiceId], "That's not an option");
    _choicesMade[msg.sender][choiceId] = choiceResponse;
    emit ChoiceMade(msg.sender, choiceId, choiceResponse);
  }

  function getNextSequence() public view returns(uint256) {
    for (uint256 i = _sequenceCache[msg.sender]; i < _sequenceCount; i++) {
      if (i == 0) {
        continue;
      }
      if (!_deletedSequences[i] && _sequenceStatuses[msg.sender][i] == SequenceStatus.NOT_DONE) {
        return i;
      }
    }
    return _sequenceCount;
  }

  function getChoice(uint256 choiceId) public view returns(uint256) {
    return _choicesMade[msg.sender][choiceId];
  }
}
