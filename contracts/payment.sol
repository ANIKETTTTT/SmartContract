// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// import "hardhat/console.sol";

contract payment {
    uint256 public nextPlanId;
    struct Plan {
        address merchant;
        uint256 amount;
        uint256 frequency;
    }
    struct Subscription {
        address subscriber;
        uint256 start;
        uint256 nextPayment;
    }
    mapping(uint256 => Plan) public plans;
    mapping(address => mapping(uint256 => Subscription)) public subscriptions;

    event PlanCreated(address merchant, uint256 planId, uint256 date);
    event SubscriptionCreated(address subscriber, uint256 planId, uint256 date);
    event SubscriptionCancelled(
        address subscriber,
        uint256 planId,
        uint256 date
    );
    event PaymentSent(
        address from,
        address to,
        uint256 amount,
        uint256 planId,
        uint256 date
    );
    uint256 count;

    function createPlan(uint256 amount, uint256 frequency) external {
        require(amount > 0, "amount needs to be > 0");
        require(frequency > 0, "frequency needs to be > 0");
        plans[nextPlanId] = Plan(msg.sender, amount, frequency);
        nextPlanId++;
    }

    function subscribe(uint256 planId) public payable {
        Plan storage plan = plans[planId];
        require(plan.merchant != address(0), "this plan does not exist");
        require(msg.value >= plan.amount, "You need to spend more ETH!");

        emit PaymentSent(
            msg.sender,
            plan.merchant,
            plan.amount,
            planId,
            block.timestamp
        );

        subscriptions[msg.sender][planId] = Subscription(
            msg.sender,
            block.timestamp,
            block.timestamp + plan.frequency
        );
        emit SubscriptionCreated(msg.sender, planId, block.timestamp);
    }

    function cancel(uint256 planId) external {
        Subscription storage subscription = subscriptions[msg.sender][planId];
        require(
            subscription.subscriber != address(0),
            "this subscription does not exist"
        );
        delete subscriptions[msg.sender][planId];
        emit SubscriptionCancelled(msg.sender, planId, block.timestamp);
    }

    function pay(address subscriber, uint256 planId) public payable {
        Subscription storage subscription = subscriptions[subscriber][planId];
        Plan storage plan = plans[planId];
        require(
            block.timestamp < subscription.nextPayment + 60,
            "Your subcription is now invalid"
        );
        require(msg.value >= plan.amount, "You need to spend more ETH!");
        require(
            subscription.subscriber != address(0),
            "this subscription does not exist"
        );

        require(block.timestamp > subscription.nextPayment, "not due yet");

        emit PaymentSent(
            subscriber,
            plan.merchant,
            plan.amount,
            planId,
            block.timestamp
        );

        subscription.nextPayment = subscription.nextPayment + plan.frequency;
    }

    function getPlan(uint256 planId) public view returns (Plan memory) {
        return plans[planId];
    }

    function getSubscriber(address sub, uint256 planId)
        public
        view
        returns (Subscription memory)
    {
        return subscriptions[sub][planId];
    }

    function getCount() public view returns (uint256) {
        return nextPlanId;
    }

    function getUser() public view returns (address) {
        return msg.sender;
    }
}
