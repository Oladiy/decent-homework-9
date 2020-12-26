pragma solidity >=0.7.0 <0.8.0;

contract CommitRevealAuction {
    event AuctionEnded(address winner, uint highestBid);

    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    address payable public beneficiary;
    address public highestBidder;

    bytes32 public lastBid;

    bool public ended;

    mapping(address => Bid[]) public bids;
    mapping(address => uint) pendingReturns;

    string public lotName;

    uint public highestBid;
    uint public biddingEnd;
    uint public revealEnd;

    /// Задаем модификаторы "только до" и "только после" для функций
    /// предложения, раскрытия и завершения аукциона
    modifier onlyBefore(uint _time) {
        require(block.timestamp < _time);
        _;
    }

    modifier onlyAfter(uint _time) {
        require(block.timestamp > _time);
        _;
    }

    constructor(
        uint _biddingTime,
        uint _revealTime,
        address payable _beneficiary,
        string memory _lotName
    ) {
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
        lotName = _lotName;
    }

    /// Разместить предложение.
    /// _blindedBid нужно задать = keccak256(abi.encodePacked(value, fake, secret)).
    /// Отправленная сумма вернется только если предложение правильно выявлено на этапе раскрытия.
    /// Допускается сделать несколько предложений на один и тот же адрес
    function bid(bytes32 _blindedBid) public payable onlyBefore(biddingEnd) {
        bids[msg.sender].push(
            Bid({
                blindedBid : _blindedBid,
                deposit : msg.value}
            )
        );
        lastBid = _blindedBid;
    }

    /// Раскрытие предложений.
    /// Все предложения, кроме наибольших, будут возвращены (если они валидны)
    function reveal(uint[] memory _values, bool[] memory _fake, bytes32[] memory _secret)
    public
    onlyAfter(biddingEnd)
    onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);
        require(_secret.length == length);
        uint refund;
        for (uint i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) = (_values[i], _fake[i], _secret[i]);
            if (bidToCheck.blindedBid != keccak256 (abi.encodePacked(value, fake, secret))) {
                // Предложение не было раскрыто - депозит не возвращается
                continue;
            }
            refund += bidToCheck.deposit;
            if (!fake && bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value)) {
                    refund -= value;
                }
            }
            // Устанавливаем значение в 0, чтобы отправитель не мог повторно получить депозит
            bidToCheck.blindedBid = bytes32(0);
        }
        payable(msg.sender).transfer(refund);
    }

    /// Отзыв предложения, которое было перекуплено
    function withdraw() public {
        uint amount = pendingReturns[msg.sender];

        if (amount > 0) {
            // Устанавливаем значение pendingReturns = 0, чтобы не произошло double spend
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    /// Завершение аукциона и трансфер наибольшего предложения beneficiary
    function auctionEnd() public onlyAfter(revealEnd) {
        require(!ended);

        emit AuctionEnded(highestBidder, highestBid);
        ended = true;

        beneficiary.transfer(highestBid);
    }

    function placeBid(address bidder, uint value) internal returns (bool success) {
        if (value <= highestBid) {
            return false;
        }

        if (highestBidder != address(0)) {
            // Возврат средств тому, кто ранее сделал наибольшее предложение
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = value;
        highestBidder = bidder;

        return true;
    }

    /// Функция для проверки, произошло ли событие
    function isHappened(uint _time) public view returns (bool) {
        return (block.timestamp > _time);
    }
}