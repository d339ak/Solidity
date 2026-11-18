// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Deployed on Sepolia:: 0x00493f75e7C36Ee6273DC3Da561bf04074762555


import {FunctionsClient} from "@chainlink/contracts@1.3.0/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts@1.3.0/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract FunctionsConsumer is FunctionsClient {

    // FunctionsRequest is the library we use to create Functions Request structs. 
    // We use the using keyword to make functions from the FunctionsRequest library callable on the Request struct variables
    using FunctionsRequest for FunctionsRequest.Request;

    string public s_lastCity;           // The latest city a Chainlink Functions got a temperature for
    string public s_requestedCity;      // The city for the latest pending Chainlink Functions request 
    string public s_lastTemperature;    // The temperature of the latest city Chainlink Functions got a temperature for

    bytes32 public s_lastRequestId;     // The ID of the latest request
    bytes public s_lastResponse;        // The response for the latest request
    bytes public s_lastError;           // The errors for the latest request

    // Hardcoded for Sepolia
    // Supported networks https://docs.chain.link/chainlink-functions/supported-networks
    address constant ROUTER = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 constant DON_ID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    //Callback gas limit
    uint32 constant GAS_LIMIT = 300000;

    // JavaScript source code
    string public  constant SOURCE =
        "const city = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://wttr.in/${city}?format=3&m`,"
        "responseType: 'text'"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data);";
    
    // Event to log responses
    event Response(bytes32 indexed requestId, string temperature, bytes response, bytes err);
    
    error UnexpectedRequestID(bytes32 requestId);    


    constructor() FunctionsClient(ROUTER) {
    }

    // getTemperature is the function we will call to get the temperature for a specific city. It takes:
    //      city: the city to get the temperature using Chainlink Functions.
    //      subscriptionId: The Chainlink Functions subscription you want to use to fund your Chainlink Functions request.
    function getTemperature(string memory city, uint64 subscriptionId ) external returns (bytes32 requestId) {
        // Remember that, in the SOURCE variable, we had the Javascript code that would be run. We need to initialize a request using this code.
        // First, we create a FunctionsRequest.Request struct, called req, which, remember, we can call functions from the FunctionsRequest library on.
        // Then, we call initializeRequestForInlineJavaScript on the req and pass the SOURCE to initialize the request.
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(SOURCE); // Initialize the request with JS code

        string[] memory args = new string[](1);
        args[0] = city;
        req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, GAS_LIMIT, DON_ID);

        // set the city for which we are obtaining the temperature
        s_requestedCity = city;

        return s_lastRequestId;
    }

    // Desc: Receive the weather in the city requested.
    // Def:  fulfillRequest is the callback function that Chainlink Functions consumer contracts must implement. 
    // The DON will call this function after the JavaScript code has been run and the request has been fulfilled
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {

        if (s_lastRequestId != requestId)
            revert UnexpectedRequestID(requestId); // Check if request IDs match

        s_lastError = err;
        s_lastResponse = response;

        s_lastTemperature = string(response);
        s_lastCity = s_requestedCity;

        // Emit an event to log the response
        emit Response(requestId, s_lastTemperature, s_lastResponse, s_lastError);        
    }
}
