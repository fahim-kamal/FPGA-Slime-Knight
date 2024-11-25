from matplotlib import pyplot as plt
from matplotlib import colors

BACKGROUND = 0
GRID = 1

BLOCK_COLOR_MAP = {"#ffffff": BACKGROUND, "#000000": GRID}


def convertLevelToBits(path: str):
    name = path.split(".")[0]
    ext = ".mem"
    f = open(name + ext, "w")

    img = plt.imread(path)
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
    name = "lvl1.png"
    convertLevelToBits(name)
