const { ethers, network } = require('hardhat');
const fs = require('fs');
const Helper = require('../test/helper/functions');

async function main() {
  const [sender] = await ethers.getSigners();

  const REQUESTS_FOLDER_PATH = './transactionRequests';

  // Take the transaction request object and the signatures and execute the transaction onchain

  const NONCE_OF_REQUEST_TO_SIGN = 1; // Change this to the request nonce (requestId)

  if (fs.existsSync(REQUESTS_FOLDER_PATH + '/' + NONCE_OF_REQUEST_TO_SIGN + '.json')) {
    const requestDetails = await fs.readFileSync(REQUESTS_FOLDER_PATH + '/' + NONCE_OF_REQUEST_TO_SIGN + '.json', 'utf8');
    const requestDetailsFormatted = JSON.parse(requestDetails);

    if (requestDetailsFormatted.txHash !== undefined) console.log('\x1b[33m', 'This request has already been executed', '\x1b[0m');

    const SimpleMultiSignature = await ethers.getContractFactory('SimpleMultiSignature');
    const simpleMultiSignature = new ethers.Contract(requestDetailsFormatted.multiSignature, SimpleMultiSignature.interface, sender);

    const threshold = await simpleMultiSignature.threshold();
    const isNonceUsed = await simpleMultiSignature.isNonceUsed(requestDetailsFormatted.txNonce);
    if (requestDetailsFormatted.signatures.length >= threshold) {
      if (!isNonceUsed) {
        // Execute transaction

        const tx = await simpleMultiSignature
          .connect(sender)
          .execTransaction(
            requestDetailsFormatted.targetAddress,
            requestDetailsFormatted.transactionValue,
            requestDetailsFormatted.transactionData,
            requestDetailsFormatted.txnGas,
            requestDetailsFormatted.txNonce,
            requestDetailsFormatted.signaturesConcatenated
          );
        console.log('tx hash', tx.hash);

        const receipt = await tx.wait();
        if (receipt.status == 1) {
          console.log('\x1b[34m', 'The transaction was executed', '\x1b[0m');
          if (receipt.events.find((event) => event.event === 'TransactionExecuted')) {
            console.log('\x1b[34m', 'The request was executed successfully', '\x1b[0m');
          } else {
            console.log('\x1b[34m', 'The request (or part of it) failed', '\x1b[0m');
          }
          const requestWithTxHash = {
            ...requestDetailsFormatted,
            txHash: tx.hash
          };
          await fs.writeFileSync(REQUESTS_FOLDER_PATH + '/' + NONCE_OF_REQUEST_TO_SIGN + '.json', JSON.stringify(requestWithTxHash, null, 2));
        } else {
          console.log('\x1b[34m', 'The transaction failed', '\x1b[0m');
        }
      } else {
        console.log('\x1b[33m', 'The nonce in this request has already be used on the contract, the transaction will fail', '\x1b[0m');
      }
    } else {
      console.log(
        '\x1b[33m',
        "You don't have enough signatures yet to execute this request, the contract threshold is " +
          threshold +
          ' and you currently have ' +
          requestDetailsFormatted.signatures.length +
          ' signature in the request file.',
        '\x1b[0m'
      );
    }
  } else {
    console.log(
      '\x1b[33m',
      'Request nonce: ' + NONCE_OF_REQUEST_TO_SIGN + ' not found in ' + REQUESTS_FOLDER_PATH + ', please make sure this nonce if valid',
      '\x1b[0m'
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
