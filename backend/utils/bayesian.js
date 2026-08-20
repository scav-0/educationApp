/**
 * Function for calculating next pKnown value
 * @param {current pKnown value} pKnown 
 * @param {pLearn == probability student will learn skill after correct answer} pLearn 
 * @param {pGuess == probability student can get correct answer without knowing it} pGuess 
 * @param {pSlip == probability of getting the answer wrong while knowing how to solve the question} pSlip 
 * @param {boolean result == true if answer to question was right, false otherwise} result 
 * @returns new Pknown value
 */
export default function PKnownNext(pKnown, pLearn, pGuess, pSlip, result) {
    const pCorrect = pKnown * (1 - pSlip) + (1 - pKnown) * pGuess;
    const pWrong = pKnown * pSlip + (1 - pKnown) * (1 - pGuess);

    const pKnownGivenAnswer = result
        ? (pKnown * (1 - pSlip)) / pCorrect
        : (pKnown * pSlip) / pWrong;

    return (pKnownGivenAnswer + (1 - pKnownGivenAnswer) * pLearn);

    //https://www.cs.williams.edu/~iris/res/bkt-balloon/index.html

}

