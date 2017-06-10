This is just a simple chat application written in K for practice.

### Running

  * start the server
  * start as many clients as you like, and choose names for each client
  * use the function `say` from a client to broadcast a message,
    e.g. `say "hi"`.

### Details

All IPC is done asynchronously. To track responses to requests, clients assign
IDs to each message they send. Each ID is unique within a client. This ID is
essentially just an arbitrary piece of state that is round-tripped through the
server, and is included in the response. This allows the client to look up in a
table of sent requests which request corresponds to a received response.

When a client sends a request, it registers a success and failure callback into
the request table. The appropriate callback is invoked when the response is
received.

There are other types of messages, which can be received without having sent a
request. These are "pushes" or "unsolicited messages". For instance, when
client A wants to broadcast a message, the server sends an unsolicited message
to all other clients. Clients register handlers for unsolicited messages into a
fixed table. For example, the handler for a message broadcast just prints out
the name of the sender and the message body.
