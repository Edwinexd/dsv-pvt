import datetime

class IdGenerator:
    last_issued = 0

    def generate_id(self) -> int:
        id_ = self.last_issued
        while id_ == self.last_issued:
            id_ = int(datetime.datetime.now(datetime.UTC).timestamp() * 1000)
        self.last_issued = id_
        return id_
