@isTest
global class MockSlackHttpResponseFailure implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ok": false, "error": "unknown_method"}');
        res.setStatusCode(500);

        return res;
    }
}