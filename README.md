# Stack-Overflow-Question-About-Unix-Sockets-in-MacOS
This repository is to display a problem I have in MacOS. As an example for a Stack Overflow questio. The problem occurs when I try to connect 2 processes with a Unix Socket. Is related with the Enitlements present in MacOS.
I came into this problem while experimenting on how to create a desktop flutter app with a python backend, and also trying to learn how sockets work at the same time.
To replicate, run both the frontend and the backend. The backend will print out the socket url in the terminal, a path in a temp dir. The frontend first displays a screen asking for the url. Then both the frontend and backend connects, and is possible to exchange messages though the flutter ui and the bakend's terminal.
The problem occurs when trying to connect from the frontend if the app-sandox entitlement is active (the address is the Unix Socket):
```
SocketException: Connection failed (OS Error: Operation not permitted, errno = 1), address = /var/folders/47/1mgmzhj92yz83yhfyhg3p01c0000gn/T/dpxTsuikQF, port = 1
```
With this example repossitory I hope to make this question easyer