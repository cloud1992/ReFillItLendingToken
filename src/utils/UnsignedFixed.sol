// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

interface IUnsignedFixed {
    type uFixed is uint;
}

abstract contract UnsignedFixed is IUnsignedFixed {
    // REVIEW: how to make this variables public regardless they belong to multiple facets of the same diamond?
    uint internal constant DECIMALS = 18;
    uint internal constant SCALE = 10 ** DECIMALS;

    uFixed internal constant ONE = uFixed.wrap(1e18);

    /**** Conversion ****/

    function toUFixed(uint a) internal pure returns (uFixed) {
        return uFixed.wrap(a * SCALE);
    }

    function toUint(uFixed a) internal pure returns (uint) {
        return uFixed.unwrap(a) / SCALE;
    }

    /**** Cast ****/

    function asUFixed(uint a) internal pure returns (uFixed) {
        return uFixed.wrap(a);
    }

    function asUFixed(uint a, uint decimals) internal pure returns (uFixed) {
        if (decimals == DECIMALS) return uFixed.wrap(a);
        else if (decimals > DECIMALS)
            return uFixed.wrap(a / (10 ** (decimals - DECIMALS)));
        else return uFixed.wrap(a * (10 ** (DECIMALS - decimals)));
    }

    function asUint(uFixed a) internal pure returns (uint) {
        return uFixed.unwrap(a);
    }

    /**** Comparisson ****/

    function isZero_(uFixed a) internal pure returns (bool) {
        return uFixed.unwrap(a) == 0;
    }

    function equal_(uFixed a, uFixed b) internal pure returns (bool) {
        return uFixed.unwrap(a) == uFixed.unwrap(b);
    }

    function less_(uFixed a, uFixed b) internal pure returns (bool) {
        return uFixed.unwrap(a) < uFixed.unwrap(b);
    }

    function lessOrEqual_(uFixed a, uFixed b) internal pure returns (bool) {
        return uFixed.unwrap(a) <= uFixed.unwrap(b);
    }

    function greater_(uFixed a, uFixed b) internal pure returns (bool) {
        return uFixed.unwrap(a) > uFixed.unwrap(b);
    }

    function greaterOrEqual_(uFixed a, uFixed b) internal pure returns (bool) {
        return uFixed.unwrap(a) >= uFixed.unwrap(b);
    }

    /**** Addition ****/

    function add_(uFixed a, uFixed b) internal pure returns (uFixed) {
        return uFixed.wrap(uFixed.unwrap(a) + uFixed.unwrap(b));
    }

    function add_(uFixed a, uint b) internal pure returns (uFixed) {
        return uFixed.wrap(uFixed.unwrap(a) + b * SCALE);
    }

    function add_(uint a, uFixed b) internal pure returns (uFixed) {
        return uFixed.wrap(a * SCALE + uFixed.unwrap(b));
    }

    /**** Substraction ****/

    function sub_(uFixed a, uFixed b) internal pure returns (uFixed) {
        return uFixed.wrap(uFixed.unwrap(a) - uFixed.unwrap(b));
    }

    function sub_(uFixed a, uint b) internal pure returns (uFixed) {
        return uFixed.wrap(uFixed.unwrap(a) - b * SCALE);
    }

    function sub_(uint a, uFixed b) internal pure returns (uFixed) {
        return uFixed.wrap(a * SCALE - uFixed.unwrap(b));
    }

    /**** Product ****/

    function mul_(uFixed a, uFixed b) internal pure returns (uFixed) {
        return uFixed.wrap((uFixed.unwrap(a) * uFixed.unwrap(b)) / SCALE);
    }

    function mul_(uFixed a, uint b) internal pure returns (uFixed) {
        return uFixed.wrap(uFixed.unwrap(a) * b);
    }

    function mul_(uint a, uFixed b) internal pure returns (uint) {
        return (a * uFixed.unwrap(b)) / SCALE;
    }

    function mulUp_(uint a, uFixed b) internal pure returns (uint) {
        return ((a * uFixed.unwrap(b)) / SCALE) + 1;
    }

    /**** Division ****/

    function div_(uFixed a, uFixed b) internal pure returns (uFixed) {
        return uFixed.wrap((uFixed.unwrap(a) * SCALE) / uFixed.unwrap(b));
    }

    function div_(uFixed a, uint b) internal pure returns (uFixed) {
        return uFixed.wrap(uFixed.unwrap(a) / b);
    }

    function div_(uint a, uFixed b) internal pure returns (uint) {
        return (a * SCALE) / uFixed.unwrap(b);
    }

    function div_(uint a, uint b) internal pure returns (uFixed) {
        return uFixed.wrap((a * SCALE) / b);
    }

    function divUp_(uFixed a, uFixed b) internal pure returns (uFixed) {
        return uFixed.wrap(((uFixed.unwrap(a) * SCALE) / uFixed.unwrap(b)) + 1);
    }

    function divUp_(uint a, uint b) internal pure returns (uFixed) {
        return uFixed.wrap(((a * SCALE) / b) + 1);
    }

    function divUp_(uint a, uFixed b) internal pure returns (uint) {
        return ((a * SCALE) / uFixed.unwrap(b)) + 1;
    }
}
