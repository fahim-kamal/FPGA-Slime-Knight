import os

from matplotlib import pyplot as plt
from matplotlib import colors

BACKGROUND = 0
GRID = 1

BLOCK_COLOR_MAP = {"#ffffff": BACKGROUND, "#000000": GRID}
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
            num = BLOCK_COLOR_MAP[hex]
            f.write(f"{num}")
            if i == d - 1:
                f.write("\n")

    f.close()


if __name__ == "__main__":
    files = os.listdir(BASE_PATH)
    pngs = list(filter(lambda name: name.split(".")[1] == "png", files))

    for png in pngs:
        convertLevelToBits(png)
