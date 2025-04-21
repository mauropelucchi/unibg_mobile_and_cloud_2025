const connect_to_db = require('./db');

// GET BY TALK HANDLER

const analyzeKeyPhrases = require('./localNLP');
const talk = require('./Talk');


module.exports.get_by_tag = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    if (!body.tag) {
        return callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch the talks. Tag is null.'
        });
    }

    body.doc_per_page = body.doc_per_page || 10;
    body.page = body.page || 1;

    try {
        await connect_to_db();
        console.log('=> get_all talks');

        const talks = await talk.find({ tags: body.tag })
            .skip((body.doc_per_page * body.page) - body.doc_per_page)
            .limit(body.doc_per_page);

        const enrichedTalks = await Promise.all(talks.map(async t => {
            if (!t.comprehend_analysis && t.description) {
                try {
                    const analysis = await analyzeKeyPhrases(t.description);
                    t.comprehend_analysis = analysis;
                    await t.save();
                } catch (err) {
                    console.error(`Comprehend error on talk ${t._id}:`, err);
                }
            }
            return t;
        }));

        return callback(null, {
            statusCode: 200,
            body: JSON.stringify(enrichedTalks)
        });

    } catch (err) {
        console.error('Error fetching talks:', err);
        return callback(null, {
            statusCode: err.statusCode || 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch the talks.'
        });
    }
};