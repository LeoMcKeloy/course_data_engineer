def brackets_validate(string):
    symbol_array = [x for x in string]
    brackets = []
    for symbol in symbol_array:
        if symbol == "{" or symbol == "[" or symbol == "(":
            brackets.append(symbol)
        elif symbol == "}":
            if len(brackets) != 0:
                if brackets.pop() == "{":
                    continue
            return False
        elif symbol == "]":
            if len(brackets) != 0:
                if brackets.pop() == "[":
                    continue
            return False
        elif symbol == ")":
            if len(brackets) != 0:
                if brackets.pop() == "(":
                    continue
            return False
    if len(brackets) == 0:
        return True
    return False
