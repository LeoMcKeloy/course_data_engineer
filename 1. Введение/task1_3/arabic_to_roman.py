import math


def arabic_to_roman(number):
    int_dict = {
        1: "I",
        5: "V",
        10: "X",
        50: "L",
        100: "C",
        500: "D",
        1000: "M"
    }

    div = 1
    while number >= div:
        div *= 10

    div /= 10

    result = ""

    while number:
        last_num = int(number / div)

        if last_num <= 3:
            result += (int_dict[div] * last_num)
        elif last_num == 4:
            result += (int_dict[div] + int_dict[div * 5])
        elif 5 <= last_num <= 8:
            result += (int_dict[div * 5] + (int_dict[div] * (last_num - 5)))
        elif last_num == 9:
            result += (int_dict[div] + int_dict[div * 10])

        number = math.floor(number % div)
        div /= 10

    return result
