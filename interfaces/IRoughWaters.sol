//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

interface IRoughWaters {

    event ScenarioUpdated(uint256 sequenceCount, uint256 choiceCount);

    event ChoiceAssigned(uint256 choiceId, uint256 sequenceId);

    event ChoiceOptionsAssigned(uint256 choiceId, uint256 optionCount);

    event SequenceFinished(address by, uint256 sequenceId);

    event SequenceSkipped(address by, uint256 sequenceId);

    event ChoiceMade(address by, uint256 choiceId, uint256 choiceResponse);

    event SequenceDeleted(uint256 sequenceId);

    event CoinsContractChanged(address previousAddress, address newAddress);

    event CollectionContractChanged(address previousAddress, address newAddress);

    event ItemsContractChanged(address previousAddress, address newAddress);

    function finishSequence(uint256 sequenceId) external;

    function makeChoice(uint256 choiceId, uint256 choiceResponse) external;

    function getNextSequence() external view returns(uint256 sequenceId);

    function getCurrencyAddress() external view returns (address);

    function claimReward() external;
}
