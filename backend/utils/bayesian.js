export default function PKnownNext(pKnown, pLearn, pGuess, pSlip, result) {
    const pCorrect = pKnown * (1 - pSlip) + (1 - pKnown) * pGuess;
    const pWrong = pKnown * pSlip + (1 - pKnown) * (1 - pGuess);

    const pKnownGivenAnswer = result
        ? (pKnown * (1 - pSlip)) / pCorrect
        : (pKnown * pSlip) / pWrong;

    return (pKnownGivenAnswer + (1 - pKnownGivenAnswer) * pLearn);

    //https://www.cs.williams.edu/~iris/res/bkt-balloon/index.html

}

