/ list of dicts representing clients
.conn: ()

/ lookup a session by socket number;
/ returns _n if there is no session
lookupsession: {:[#.conn; * .conn[& x = .conn[;`h]]; _n]}

/ message format:
/ every message is an object with two or three keys.
/ The two required keys are `type and `body.
/ `type identifies which operation the server should perform.
/ `body identifies arguments specific to that operation.
/ The optional key is `state which is a custom piece of data that will be
/ included in the asynchronous response to the client. The client ensures that
/ these values are unique across its requests, so that it can identify which
/ response matches which request.

/ Constructs an ok response
ok: { [msg]
    .( (`type; `ok) ; (`body; msg.type) ; (`state; msg.state) ) }

/ Constructs a failure response, with the given body.
fail: { [msg; info]
    .( (`type; `fail) ; (`body; info) ; (`state; msg.state) ) }

/ Constructs a right value
right: {.,(`r; x) }
/ Constructs a left value
left: {.,(`l; x) }

/ construct a left value, but also print out
leftp: { `0: , x ; left x }

/ Deconstructs an either value.
either: { [l;r;e]
    if[`l _in ! e; : l e.l]
    if[`r _in ! e; : r e.r] }
    / TODO signal an error?!

/ msg:
/   name: friendly name of the sender
.chat.join: {[msg]
    if[~ _n ~ lookupsession _w;
        : leftp "user " , (5: msg.name) , " is already joined"]

    .conn,: .((`h; _w); (`name; msg.name))
    `0: ,"join for user " , (5: _w) , " aka " , msg.name , " successful"

    right _n}

.chat.leave: {[msg]
    if[_n ~ lookupsession _w;
        : leftp "user " , (5: _w) , " has not joined!"]

    .conn _di & _w = .conn[;`h]
    right _n}

/ msg: text content of the message
/
/ The object send to clients will have type `msg
/ the body will be an object with keys `sender and `body
.chat.send: {[msg]
    / check that the user sending the message has joined
    if[_n ~ session: lookupsession _w;
        : leftp "user sending message " , (5: msg) , " has no session" ]

    / send the message to everyone except the sender
    body: .( (`sender; session.name) ; (`body; msg) )
    hs[& ~ _w = hs: .conn[;`h]] 3:\: .( (`type; `msg) ; (`body; body) )

    right _n}


.m.s: {[cmd]
    `0: ,"got command: " , 5: cmd
    if[_n ~ h: .chat[cmd.type];
        `0: , "unknown command received " , (5: msg)]

    either[{_w 3: fail[cmd; x]} ; {_w 3: ok cmd} ; h cmd `body]
}

\m i 1234
`0: ,"listening on port 1234"
