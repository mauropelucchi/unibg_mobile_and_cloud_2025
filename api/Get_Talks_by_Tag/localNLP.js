const nlp = require('compromise');

function analyzeKeyPhrases(text) {
    const doc = nlp(text);
    const nouns = doc.nouns().out('array');
    const verbs = doc.verbs().out('array');

    return {
        KeyPhrases: [...new Set([...nouns, ...verbs])]
    };
}

module.exports = analyzeKeyPhrases;