#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

TOKENSOL=`grep ^TOKENSOL= settings.txt | sed "s/^.*=//"`
TOKENJS=`grep ^TOKENJS= settings.txt | sed "s/^.*=//"`
TESTSOL=`grep ^TESTSOL= settings.txt | sed "s/^.*=//"`
TESTJS=`grep ^TESTJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

START_DATE=`echo "$CURRENTTIME+60*2+30" | bc`
START_DATE_S=`date -r $START_DATE -u`
END_DATE=`echo "$CURRENTTIME+60*4" | bc`
END_DATE_S=`date -r $END_DATE -u`

printf "MODE               = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT    = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD           = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR          = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "TOKENSOL           = '$TOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "TOKENJS            = '$TOKENJS'\n" | tee -a $TEST1OUTPUT
printf "TESTSOL            = '$TESTSOL'\n" | tee -a $TEST1OUTPUT
printf "TESTJS             = '$TESTJS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA     = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS          = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT        = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS       = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME        = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE         = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE           = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/* .`
# `cp modifiedContracts/* .`

# --- Modify parameters ---
# `perl -pi -e "s/START_DATE \= 1512921600;.*$/START_DATE \= $START_DATE; \/\/ $START_DATE_S/" $CROWDSALESOL`
# `perl -pi -e "s/maxSupply \= 500000000;.*$/maxSupply \= 500000000 \* 10\*\*18;/" *.sol`

for FILE in *.sol
do
  DIFFS1=`diff $SOURCEDIR/$FILE $FILE`
  echo "--- Differences $SOURCEDIR/$FILE $FILE ---" | tee -a $TEST1OUTPUT
  echo "$DIFFS1" | tee -a $TEST1OUTPUT
done

solc_0.4.20 --version | tee -a $TEST1OUTPUT

echo "var tokenOutput=`solc_0.4.20 --optimize --pretty-json --combined-json abi,bin,interface $TOKENSOL`;" > $TOKENJS
echo "var testTokenFallbackOutput=`solc_0.4.20 --optimize --pretty-json --combined-json abi,bin,interface $TESTSOL`;" > $TESTJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$TOKENJS");
loadScript("$TESTJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["$TOKENSOL:SHIPToken"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$TOKENSOL:SHIPToken"].bin;
var testTokenFallbackAbi = JSON.parse(testTokenFallbackOutput.contracts["$TESTSOL:TestTokenFallback"].abi);
var testTokenFallbackBin = "0x" + testTokenFallbackOutput.contracts["$TESTSOL:TestTokenFallback"].bin;

// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));
// console.log("DATA: testTokenFallbackAbi=" + JSON.stringify(testTokenFallbackAbi));
// console.log("DATA: testTokenFallbackBin=" + JSON.stringify(testTokenFallbackBin));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

var fullTest = true;


// -----------------------------------------------------------------------------
var deployTokenMessage = "Deploy Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployTokenMessage + " ----------");
var tokenContract = web3.eth.contract(tokenAbi);
var tokenTx = null;
var tokenAddress = null;
var currentBlock = eth.blockNumber;
var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenTx, deployTokenMessage);
printTxData("tokenTx", tokenTx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deployTestTokenFallbackMessage = "Deploy TestTokenFallback Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + deployTestTokenFallbackMessage + " ----------");
var testTokenFallbackContract = web3.eth.contract(testTokenFallbackAbi);
var testTokenFallbackTx = null;
var testTokenFallbackAddress = null;
var testTokenFallback = testTokenFallbackContract.new({from: contractOwnerAccount, data: testTokenFallbackBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        testTokenFallbackTx = contract.transactionHash;
      } else {
        testTokenFallbackAddress = contract.address;
        addAccount(testTokenFallbackAddress, "TestTokenFallback");
        addTestTokenFallbackContractAddressAndAbi(testTokenFallbackAddress, testTokenFallbackAbi);
        console.log("DATA: testTokenFallbackAddress=" + testTokenFallbackAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(testTokenFallbackTx, deployTestTokenFallbackMessage);
printTxData("testTokenFallbackTx", testTokenFallbackTx);
printTestTokenFallbackContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mintTokens0Message = "Mint Tokens #1";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + mintTokens0Message + " ----------");
var mintTokens0_1Tx = token.mint(account3, "123456789000000000000000", {from: contractOwnerAccount, gas: 1000000, gasPrice: defaultGasPrice});
var mintTokens0_2Tx = token.mint(account4, "234567890000000000000000", {from: contractOwnerAccount, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(mintTokens0_1Tx, mintTokens0Message + " - ac3 + 123456.789 SHIP");
failIfTxStatusError(mintTokens0_2Tx, mintTokens0Message + " - ac4 + 234567.890 SHIP");
printTxData("mintTokens0_1Tx", mintTokens0_1Tx);
printTxData("mintTokens0_2Tx", mintTokens0_2Tx);
printTokenContractDetails();
console.log("RESULT: ");


if (fullTest) {
// -----------------------------------------------------------------------------
var transfer1_Message = "Move Non-0 Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + transfer1_Message + " ----------");
var transfer1_1Tx = token.transfer(account5, "1000000000000", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
var transfer1_2Tx = token.approve(account6,  "30000000000000000", {from: account4, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transfer1_3Tx = token.transferFrom(account4, account7, "30000000000000000", {from: account6, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("transfer1_1Tx", transfer1_1Tx);
printTxData("transfer1_2Tx", transfer1_2Tx);
printTxData("transfer1_3Tx", transfer1_3Tx);
failIfTxStatusError(transfer1_1Tx, transfer1_Message + " - transfer 0.000001 tokens ac3 -> ac5. CHECK for movement");
failIfTxStatusError(transfer1_2Tx, transfer1_Message + " - approve 0.03 tokens ac4 -> ac6");
failIfTxStatusError(transfer1_3Tx, transfer1_Message + " - transferFrom 0.03 tokens ac4 -> ac7 by ac6. CHECK for movement");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transfer2_Message = "Move 0 Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + transfer2_Message + " ----------");
var transfer2_1Tx = token.transfer(account5, "0", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
var transfer2_2Tx = token.approve(account6,  "0", {from: account4, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transfer2_3Tx = token.transferFrom(account4, account7, "0", {from: account6, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("transfer2_1Tx", transfer2_1Tx);
printTxData("transfer2_2Tx", transfer2_2Tx);
printTxData("transfer2_3Tx", transfer2_3Tx);
failIfTxStatusError(transfer2_1Tx, transfer2_Message + " - transfer 0 tokens ac3 -> ac5. CHECK for 0 movement");
failIfTxStatusError(transfer2_2Tx, transfer2_Message + " - approve 0 tokens ac4 -> ac6");
failIfTxStatusError(transfer2_3Tx, transfer2_Message + " - transferFrom 0 tokens ac4 -> ac7 by ac6. CHECK for 0 movement");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transfer3_Message = "Move Too Many Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + transfer3_Message + " ----------");
var transfer3_1Tx = token.transfer(account5, "234567890000000000000000", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
var transfer3_2Tx = token.approve(account6,  "234567890000000000000000", {from: account4, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transfer3_3Tx = token.transferFrom(account4, account7, "234567890000000000000000", {from: account6, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("transfer3_1Tx", transfer3_1Tx);
printTxData("transfer3_2Tx", transfer3_2Tx);
printTxData("transfer3_3Tx", transfer3_3Tx);
passIfTxStatusError(transfer3_1Tx, transfer3_Message + " - transfer 234567.890 tokens ac3 -> ac5. Expecting failure");
failIfTxStatusError(transfer3_2Tx, transfer3_Message + " - approve 234567.890 tokens ac4 -> ac6");
passIfTxStatusError(transfer3_3Tx, transfer3_Message + " - transferFrom 234567.890 tokens ac4 -> ac7 by ac6. Expecting failure");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendEthMessage = "Send Ethers To Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + sendEthMessage + " ----------");
var sendEth0_1Tx = eth.sendTransaction({from: contractOwnerAccount, to: tokenAddress, gas: 400000, value: web3.toWei("2.5", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
passIfTxStatusError(sendEth0_1Tx, sendEthMessage + " - owner 2.5 ETH. Expecting to fail");
printTxData("sendEth0_1Tx", sendEth0_1Tx);
printTokenContractDetails();
console.log("RESULT: ");
}


if (false) {
// -----------------------------------------------------------------------------
var transferAndCall1_Message = "transferAndCall";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + transferAndCall1_Message + " ----------");
var transferAndCall1_1Tx = token.transferAndCall(testTokenFallbackAddress, "1000000000000000000", "requireFlag=true,successFlag=true", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transferAndCall1_2Tx = testTokenFallback.setRequireFlag(false, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transferAndCall1_3Tx = token.transferAndCall(testTokenFallbackAddress, "2000000000000000000", "requireFlag=false,successFlag=true", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transferAndCall1_4Tx = testTokenFallback.setRequireFlag(true, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var transferAndCall1_5Tx = testTokenFallback.setSuccessFlag(false, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transferAndCall1_6Tx = token.transferAndCall(testTokenFallbackAddress, "3000000000000000000", "requireFlag=true,successFlag=false", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transferAndCall1_7Tx = testTokenFallback.setRequireFlag(false, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var transferAndCall1_8Tx = testTokenFallback.setSuccessFlag(false, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transferAndCall1_9Tx = token.transferAndCall(testTokenFallbackAddress, "4000000000000000000", "requireFlag=false,successFlag=false", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var transferAndCall1_10Tx = testTokenFallback.setRequireFlag(true, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var transferAndCall1_11Tx = testTokenFallback.setSuccessFlag(true, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("transferAndCall1_1Tx", transferAndCall1_1Tx);
printTxData("transferAndCall1_2Tx", transferAndCall1_2Tx);
printTxData("transferAndCall1_3Tx", transferAndCall1_3Tx);
printTxData("transferAndCall1_4Tx", transferAndCall1_4Tx);
printTxData("transferAndCall1_5Tx", transferAndCall1_5Tx);
printTxData("transferAndCall1_6Tx", transferAndCall1_6Tx);
printTxData("transferAndCall1_7Tx", transferAndCall1_7Tx);
printTxData("transferAndCall1_8Tx", transferAndCall1_8Tx);
printTxData("transferAndCall1_9Tx", transferAndCall1_9Tx);
printTxData("transferAndCall1_10Tx", transferAndCall1_10Tx);
printTxData("transferAndCall1_11Tx", transferAndCall1_11Tx);
failIfTxStatusError(transferAndCall1_1Tx, transferAndCall1_Message + " - transferAndCall(testTokenFallback, 1 token, 'requireFlag=true,successFlag=true')");
failIfTxStatusError(transferAndCall1_2Tx, transferAndCall1_Message + " - setRequireFlag(false)");
passIfTxStatusError(transferAndCall1_3Tx, transferAndCall1_Message + " - transferAndCall(testTokenFallback, 2 token, 'requireFlag=false,successFlag=true')");
failIfTxStatusError(transferAndCall1_4Tx, transferAndCall1_Message + " - setRequireFlag(true)");
failIfTxStatusError(transferAndCall1_5Tx, transferAndCall1_Message + " - setSuccessFlag(false)");
passIfTxStatusError(transferAndCall1_6Tx, transferAndCall1_Message + " - transferAndCall(testTokenFallback, 3 token, 'requireFlag=true,successFlag=false')");
failIfTxStatusError(transferAndCall1_7Tx, transferAndCall1_Message + " - setRequireFlag(false)");
failIfTxStatusError(transferAndCall1_8Tx, transferAndCall1_Message + " - setSuccessFlag(false)");
passIfTxStatusError(transferAndCall1_9Tx, transferAndCall1_Message + " - transferAndCall(testTokenFallback, 4 token, 'requireFlag=false,successFlag=false')");
failIfTxStatusError(transferAndCall1_10Tx, transferAndCall1_Message + " - setRequireFlag(true)");
failIfTxStatusError(transferAndCall1_11Tx, transferAndCall1_Message + " - setSuccessFlag(true)");
printTokenContractDetails();
printTestTokenFallbackContractDetails();
console.log("RESULT: ");
}


// -----------------------------------------------------------------------------
var approveAndCall1_Message = "approveAndCall";
// -----------------------------------------------------------------------------
console.log("RESULT: ---------- " + approveAndCall1_Message + " ----------");
var approveAndCall1_1Tx = token.approveAndCall(testTokenFallbackAddress, "1000000000000000000", "requireFlag=true,successFlag=true", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var approveAndCall1_2Tx = testTokenFallback.setRequireFlag(false, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var approveAndCall1_3Tx = token.approveAndCall(testTokenFallbackAddress, "2000000000000000000", "requireFlag=false,successFlag=true", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var approveAndCall1_4Tx = testTokenFallback.setRequireFlag(true, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var approveAndCall1_5Tx = testTokenFallback.setSuccessFlag(false, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var approveAndCall1_6Tx = token.approveAndCall(testTokenFallbackAddress, "3000000000000000000", "requireFlag=true,successFlag=false", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var approveAndCall1_7Tx = testTokenFallback.setRequireFlag(false, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var approveAndCall1_8Tx = testTokenFallback.setSuccessFlag(false, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var approveAndCall1_9Tx = token.approveAndCall(testTokenFallbackAddress, "4000000000000000000", "requireFlag=false,successFlag=false", {from: account3, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("approveAndCall1_1Tx", approveAndCall1_1Tx);
printTxData("approveAndCall1_2Tx", approveAndCall1_2Tx);
printTxData("approveAndCall1_3Tx", approveAndCall1_3Tx);
printTxData("approveAndCall1_4Tx", approveAndCall1_4Tx);
printTxData("approveAndCall1_5Tx", approveAndCall1_5Tx);
printTxData("approveAndCall1_6Tx", approveAndCall1_6Tx);
printTxData("approveAndCall1_7Tx", approveAndCall1_7Tx);
printTxData("approveAndCall1_8Tx", approveAndCall1_8Tx);
printTxData("approveAndCall1_9Tx", approveAndCall1_9Tx);
failIfTxStatusError(approveAndCall1_1Tx, approveAndCall1_Message + " - approveAndCall(testTokenFallback, 1 token, 'requireFlag=true,successFlag=true')");
failIfTxStatusError(approveAndCall1_2Tx, approveAndCall1_Message + " - setRequireFlag(false)");
passIfTxStatusError(approveAndCall1_3Tx, approveAndCall1_Message + " - approveAndCall(testTokenFallback, 2 token, 'requireFlag=false,successFlag=true')");
failIfTxStatusError(approveAndCall1_4Tx, approveAndCall1_Message + " - setRequireFlag(true)");
failIfTxStatusError(approveAndCall1_5Tx, approveAndCall1_Message + " - setSuccessFlag(false)");
failIfTxStatusError(approveAndCall1_6Tx, approveAndCall1_Message + " - approveAndCall(testTokenFallback, 3 token, 'requireFlag=true,successFlag=false')");
failIfTxStatusError(approveAndCall1_7Tx, approveAndCall1_Message + " - setRequireFlag(false)");
failIfTxStatusError(approveAndCall1_8Tx, approveAndCall1_Message + " - setSuccessFlag(false)");
passIfTxStatusError(approveAndCall1_9Tx, approveAndCall1_Message + " - approveAndCall(testTokenFallback, 4 token, 'requireFlag=false,successFlag=false')");
printTokenContractDetails();
printTestTokenFallbackContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
