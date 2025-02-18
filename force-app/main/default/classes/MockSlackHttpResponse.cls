@isTest
global class MockSlackHttpResponse implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (req.getEndpoint().contains('users.lookupByEmail')) {
            // Mock response for getSlackUserID
            res.setBody('{"ok": true, "user": {"id": "U123456"}}');
            res.setStatusCode(200);
        } else if (req.getEndpoint().contains('conversations.open')) {
            // Mock response for createSlackChannel
            res.setBody('{"ok": true, "channel": {"id": "C987654"}}');
            res.setStatusCode(200);
        } else if (req.getEndpoint().contains('chat.postMessage')) {
            // Mock response for postMessage
            res.setBody('{"ok": true, "channel": {"id": "C987654"}}');
            res.setStatusCode(200);
        } else {
            res.setBody('{"ok": false, "error": "unknown_method"}');
            res.setStatusCode(400);
        }

        return res;
    }
}