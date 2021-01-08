import re


def camelcase(string):
    """ Convert string into camel case.
    Args:
        string: String to convert.
    Returns:
        string: Camel case string.
    """

    string = re.sub(r"^[\-_\.]", '', str(string))
    if not string:
        return string
    return lowercase(string[0]) + re.sub(r"[\-_\.\s]([a-z])", lambda matched: uppercase(matched.group(1)), string[1:])

def capitalcase(string):
    """Convert string into capital case.
    First letters will be uppercase.
    Args:
        string: String to convert.
    Returns:
        string: Capital case string.
    """

    string = str(string)
    if not string:
        return string
    return uppercase(string[0]) + string[1:]

def lowercase(string):
    """Convert string into lower case.
    Args:
        string: String to convert.
    Returns:
        string: Lowercase case string.
    """

    return str(string).lower()

def pascalcase(string):
    """Convert string into pascal case.
    Args:
        string: String to convert.
    Returns:
        string: Pascal case string.
    """

    return capitalcase(camelcase(string))

def snakecase(string):
    """Convert string into snake case.
    Join punctuation with underscore
    Args:
        string: String to convert.
    Returns:
        string: Snake cased string.
    """

    string = re.sub(r"[\-\.\s]", '_', str(string))
    if not string:
        return string
    return lowercase(string[0]) + re.sub(r"[A-Z]", lambda matched: '_' + lowercase(matched.group(0)), string[1:])

def spinalcase(string):
    """Convert string into spinal case.
    Join punctuation with hyphen.
    Args:
        string: String to convert.
    Returns:
        string: Spinal cased string.
    """

    return re.sub(r"_", "-", snakecase(string))

def uppercase(string):
    """Convert string into upper case.
    Args:
        string: String to convert.
    Returns:
        string: Uppercase case string.
    """

    return str(string).upper()

def uppersnakecase(string):
    """Convert string into upper snake case.
    Join punctuation with underscore and convert letters into uppercase.
    Args:
        string: String to convert.
    Returns:
        string: Const cased string.
    """

    return uppercase(snakecase(string))
