import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {WETH9} from "../../src/WETH9.sol";
import {AddressSet, LibAddressSet} from "../helpers/AddressSet.sol";

contract Handler is CommonBase, StdCheats, StdUtils {
    using LibAddressSet for AddressSet;

    WETH9 public weth;

    uint256 public ghost_depositSum;
    uint256 public ghost_withdrawSum;

    uint public constant ETH_SUPPLY = 120500000 ether;

    AddressSet internal _actors;
    address internal currentActor;

    modifier createActor() {
        currentActor = msg.sender;
        _actors.add(msg.sender);
        _;
    }

    constructor(WETH9 _weth) {
        weth = _weth;
        deal(address(this), ETH_SUPPLY);
    }

    function deposit(uint256 amount) public createActor {
        amount = bound(amount, 0, address(this).balance);

        _pay(currentActor, amount);

        vm.prank(currentActor);
        weth.deposit{value: amount}();
        ghost_depositSum += amount;
    }

    function withdraw(uint256 amount) public {
        amount = bound(amount, 0, weth.balanceOf(msg.sender));

        vm.startPrank(currentActor);
        weth.withdraw(amount);

        _pay(address(this), amount);

        vm.stopPrank();

        ghost_withdrawSum -= amount;
    }

    function sendFallback(uint256 amount) public createActor {
        amount = bound(amount, 0, address(this).balance);

        _pay(currentActor, amount);
        vm.prank(currentActor);

        (bool success, ) = address(weth).call{value: amount}("");
        require(success, "sendFallback failed");

        ghost_depositSum += amount;
    }

    // To use these iterators from our tests,
    // we can expose them from the handler (forEachActor and reduceActors)

    function forEachActor(function(address) external func) public {
        return _actors.forEach(func);
    }

    // error[9553]: TypeError: Invalid type for argument in function call. Invalid implicit conversion from function (address) external to function (address) external returns (address[] memory) requested.

    function reduceActors(
        uint256 acc,
        function(uint256, address) external returns (uint256) func
    ) public returns (uint256) {
        return _actors.reduce(acc, func);
    }

    function actors() external returns (address[] memory) {
        return _actors.addrs;
    }

    function _pay(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}("");
        require(success, "call failed");
    }

    receive() external payable {}
}
