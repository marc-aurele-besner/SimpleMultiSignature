const { ethers, network } = require('hardhat');
const fs = require('fs');
const Helper = require('../test/helper/functions');

async function main() {
  const [signer] = await ethers.getSigners();

  const REQUESTS_FOLDER_PATH = './transactionRequests';
  // Take a transaction request object and sign it with the current private key in .env and return a signature

  const NONCE_OF_REQUEST_TO_SIGN = 0; // Change this to the request nonce (requestId)

  if (fs.existsSync(REQUESTS_FOLDER_PATH + '/' + NONCE_OF_REQUEST_TO_SIGN + '.json')) {
    const requestDetails = await fs.readFileSync(REQUESTS_FOLDER_PATH + '/' + NONCE_OF_REQUEST_TO_SIGN + '.json', 'utf8');
    const requestDetailsFormatted = JSON.parse(requestDetails);

    if (requestDetailsFormatted.ownersSigners.find((owner) => owner === signer.address))
      console.log('\x1b[33m', 'You appear to already have signed this request', '\x1b[0m');
    else {
      const signature = await Helper.generateSignatures(
        requestDetailsFormatted.multiSignature,
        [signer],
        requestDetailsFormatted.targetAddress,
        requestDetailsFormatted.transactionValue,
        requestDetailsFormatted.transactionData,
        requestDetailsFormatted.txnGas,
        requestDetailsFormatted.txNonce
      );

      let signaturesConcatenatedWithNewSignature = requestDetailsFormatted.signaturesConcatenated;
      if (signaturesConcatenatedWithNewSignature === '') signaturesConcatenatedWithNewSignature = signature;
      else signaturesConcatenatedWithNewSignature += String(signature).substring(2);

      const requestWithSignatures = {
        ...requestDetailsFormatted,
        ownersSigners: [...requestDetailsFormatted.ownersSigners, signer.address],
        signatures: [...requestDetailsFormatted.signatures, signature],
        signaturesConcatenated: signaturesConcatenatedWithNewSignature
      };
      console.log('requestWithSignatures', requestWithSignatures);

      await fs.writeFileSync(REQUESTS_FOLDER_PATH + '/' + NONCE_OF_REQUEST_TO_SIGN + '.json', JSON.stringify(requestWithSignatures));

      console.log('\x1b[32m', 'Multisig request with signature saved in ' + REQUESTS_FOLDER_PATH + ', please commit to GitHub this request', '\x1b[0m');
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
