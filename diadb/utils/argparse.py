import os
from typing import Callable


def clear_environ(rule: Callable):
    """
    Clears environment variables, rule - function that defines
    the list of environment variables to clear.
    """
    # Keys from os.environ are being copied into a new tuple, to avoid
    # changing of object os.environ while we're iterating through it.
    for name in filter(rule, tuple(os.environ)):
        os.environ.pop(name)
