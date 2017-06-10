/ connect to the server
h: 3: (`;1234)

/ list of dicts, each dict having keys
/ `state (id of request)
/ `callback (function to run on received data when response is received)
.reqs: ()

.reqnum: 0
nextreqnum: { n: .reqnum ; .reqnum+: 1 ; n }

/ prepares a callback to handle success or failure, and registers the request
/ in the table of pending requests, and sends the request.
/ the message object passed in is augmented with a `state key holding its id in
/ the table
request: {[msg;onOk;onFail]
    cb: .( (`ok ; onOk) ; (`fail ; onFail) )
    msg.state: nextreqnum[]
    .reqs,: .( (`state; msg.state) ; (`callback; {cb[x.type;x.body]}) )
    h 3: msg}

/ handler for messages containing a `state key (which are only those of type
/ `ok and `fail)
responsehandler: {[msg]
    / look up the request in the table
    if[_n ~ req: .reqs[* & msg.state = .reqs[;`state]];
        `0: , "unsolicited response: " , $ msg.state
        : _n]

    req.callback msg}

.handlers.msg: {[msg]
    `0: , msg.sender , ": " , msg.body}

.m.s: {[msg]
    / handle responses
    if[`state _in ! msg;
        : responsehandler msg]

    / handle "unsolicited" messages, i.e. messages sent server -> client
    .handlers[msg.type] msg.body}

.internal.join: {[nick]
    request[ .( (`type; `join) ; (`body; .,(`name; nick)) )
        {`0: ,"joined chat"}
        {`0: ,"joining chat failed"}]}

`0: "Your nick for chat: "
nick: 0:`

.internal.join nick

say: {[str]
    request[.( (`type; `send); (`body; str) ); {`0: ,"ok"}; {`0: ,"uh oh"}]}
