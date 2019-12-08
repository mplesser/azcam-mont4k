"""
reset controller repeatedly
"""

import sys

import azcam


def test_reset(Cycles=10):

    Cycles = azcam.api.get_parfile_par(
        "test_reset", "Cycles", "prompt", "Enter number of reset cycles", Cycles
    )
    Cycles = int(Cycles)

    # **************************************************************
    # Loop
    # **************************************************************
    print("Resetting controller...")
    for i in range(Cycles):
        print("Cycle %d of %d" % (i + 1, Cycles))
        reply = azcam.api.reset()
        if azcam.utils.check_reply(reply):
            print(reply)
            break

    if azcam.utils.check_reply(reply):
        print("Reset test FAIL:", reply)
    else:
        print("Reset test PASS")

    return


if __name__ == "__main__":
    args = sys.argv[1:]
    test_reset(*args)
