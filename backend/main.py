import os
import random
import socket
import string
import tempfile
import threading
from pathlib import Path
from typing import Callable

from message_comunication import send_msg, recv_msg


def random_string(length):
    return "".join(random.choice(string.ascii_letters) for i in range(length))


class Connection:
    def __init__(self, on_message_received: Callable[[str], None]):
        self.active = True
        self.__connection = None

        self.on_message_received = on_message_received

        self.url = str(Path(tempfile.gettempdir()).joinpath(random_string(10)))
        self.__socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.__socket.bind(self.url)
        self.__socket.listen(1)

        thread = threading.Thread(target=self.__connection_loop, args=(), daemon=True)
        thread.start()

    def send(self, message: str):
        if not self.__connection:
            return

        message_bytes = message.encode("utf-8")
        send_msg(self.__connection, message_bytes)

    def close(self):
        self.active = False

        if self.__socket:
            self.__socket.close()

        if self.url and os.path.exists(self.url):
            os.unlink(self.url)

    def __connection_loop(self):
        while self.active:
            self.__connection, client_address = self.__socket.accept()
            try:
                self.__message_loop()
            finally:
                self.__connection.close()

    def __message_loop(self):
        while self.active and self.__connection:
            raw_message = recv_msg(self.__connection)
            if not raw_message:
                continue
            message = raw_message.decode("utf-8")

            self.on_message_received(message)


if __name__ == '__main__':
    connection = Connection(lambda x: print(x))
    print(f"Connection path: {connection.url}")

    while True:
        inputted_message = input("Message: ")
        if inputted_message == "close":
            break

        connection.send(inputted_message)
