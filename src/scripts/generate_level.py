import os

from matplotlib import pyplot as plt
from matplotlib import colors

BACKGROUND_BRICK = 0
FOREGROUND_BRICK = 1
HALF_SLAB = 2
EXIT_DOOR = 3

WHITE = "#ffffff"
BLACK = "#000000"
GRAY = "#737373"
BROWN = "#804d00"

COLOR_BLOCK_MAP = {
    WHITE: BACKGROUND_BRICK,
    BLACK: FOREGROUND_BRICK,
    GRAY: HALF_SLAB,
    BROWN: EXIT_DOOR,
}

BASE_PATH = "../levels"


def convertLevelToBits(path: str):
    name = path.split(".")[0]

    inputFilePath = os.path.join(BASE_PATH, name + ".png")
    outputFilePath = os.path.join(BASE_PATH, name + ".mem")

    f = open(outputFilePath, "w")

    img = plt.imread(inputFilePath)
    d = img.shape[1]

    for row in img:
        for i, col in enumerate(row):
            hex = colors.to_hex(col)
            num = COLOR_BLOCK_MAP[hex]
            f.write(f"{bin(num)[2:].rjust(3, '0')}")
            if i == d - 1:
                f.write("\n")
            else:
                f.write(" ")

    f.close()


if __name__ == "__main__":
    files = os.listdir(BASE_PATH)
    pngs = list(filter(lambda name: name.split(".")[1] == "png", files))

    for png in pngs:
        convertLevelToBits(png)
