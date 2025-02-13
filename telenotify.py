import urllib.error
import urllib.parse
import urllib.request

class _HTTPStatusCode:
    OK = 200
    BAD_REQUEST = 400
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404

class UnauthorizedError(BaseException):
    pass

class EmptyMessageError(BaseException):
    pass

class Telenotify:
    def __init__(self, status: bool, bot_token: str, chat_id: int | str) -> None:
        """
        ## Discription:
        That's module for send simple messages or notifies to telegram account

        ## Args:
        - `status`: [bool] - Uses for turn on on off the notifies.
        - `bot_token`: [str] - Token of your bot.
        - `chat_id`: [str | int] - Your telegram account id.

        ## Fast start:
        ``` python
        from telenotify import Telenotify

        TOKEN = '123456789:JhskaJHGHjsad...'
        CHAT_ID = 132456789
        status = True

        tnotify = Telenotify(status=status, bot_token=TOKEN, chat_id=CHAT_ID)
        ```
        """
        self.status = status
        self.SEND_MESSAGE_URL = f"https://api.telegram.org/bot{bot_token}/sendMessage"
        self.CHAT_ID = chat_id
        
    def send_message(self, message: str | int = '') -> _HTTPStatusCode:
        """
        ## Discription:
        Sends default, markdown formated message.
        ## Args:
        - message: Optional[str] - Text of message.
        """
        if self.status:
            if message == '':
                raise EmptyMessageError("Message can't be empty")
            try:
                payload = dict(
                    chat_id=self.CHAT_ID,
                    text=message,
                    parse_mode='Markdown'
                    )
                data = urllib.parse.urlencode(payload).encode('ascii')
                urllib.request.urlopen(self.SEND_MESSAGE_URL, data=data)
                return _HTTPStatusCode.OK
            
            except urllib.error.HTTPError:
                raise UnauthorizedError('Probably missing chat with bot or invalid token/chat_id', _HTTPStatusCode.UNAUTHORIZED)   
    