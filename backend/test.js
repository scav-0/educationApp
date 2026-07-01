import PKnownNext from "./utils/bayesian.js";


/**
 * Testing the knowledge tracing for different values for the probabilities
 */
let pKnown =0.01;
let i=2;
while(pKnown<=0.95){
    let correct = true;
    if(i%3==0){
        correct=false;
    }
    pKnown = PKnownNext(pKnown, 0.01, 0.25, 0.1, correct);
    console.log(pKnown);
    i++;
}