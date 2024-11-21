length = 6
curval = 0

with open("../docs/usedopcodes.csv", "w") as f:
    for a1 in range(2):
        for a2 in range(2):
            for a3 in range(2):
                for a4 in range(2):
                    for a5 in range(2):
                        for a6 in range(2):
                            f.write(f"{a1}{a2}{a3}{a4}{a5}{a6}")
                            f.write("\n")
