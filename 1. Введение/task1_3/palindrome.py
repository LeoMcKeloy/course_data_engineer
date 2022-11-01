def palindrome(string):
    string = string.replace(" ", "")
    return string == string[::-1]
