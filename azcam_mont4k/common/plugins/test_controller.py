"""
test controller.
"""

import sys
import time
import azcam


def test_controller(Cycles=10):

    Cycles = azcam.api.get_parfile_par(
        "test_controller", "Cycles", "prompt", "Enter number of test cycles", Cycles
    )
    Cycles = int(Cycles)

    # loop through boards
    print("\nTesting controller board level communications...")
    if int(azcam.api.get_attr("controller", "pci_board_installed")):
        print("PCI board:")
        for loop in range(Cycles):
            reply = azcam.api.rcommand("controller.test_datalink 1 111 1 ")
            if azcam.utils.check_reply(reply):
                return "ERROR with PCI board communication: %s" % reply[1]
            else:
                print("PCI board communication OK %d/%d" % (loop + 1, Cycles))

    if int(azcam.api.get_attr("controller", "timing_board_installed")):
        print("\nTiming board:")
        for loop in range(Cycles):
            reply = azcam.api.rcommand("controller.test_datalink 2 222 1 ")
            if azcam.utils.check_reply(reply):
                return "ERROR with Timing board communication: %s" % reply[1]
            else:
                print("Timing board communication OK %d/%d" % (loop + 1, Cycles))

    if int(azcam.api.get_attr("controller", "utility_board_installed")):
        print("\nUtility board:")
        for loop in range(Cycles):
            reply = azcam.api.rcommand("controller.test_datalink 3 333 1 ")
            if azcam.utils.check_reply(reply):
                return "ERROR with utility communication: %s" % reply[1]
            else:
                print("Utility board communication OK %d/%d" % (loop + 1, Cycles))

    print("*** Board communication is communication OK ***")

    # reset
    print("\nTesting basic communication and reset...")
    for loop in range(Cycles):
        if loop > 0:
            time.sleep(1)  # delay for Mag DSP file lock
        reply = azcam.api.reset()
        if azcam.utils.check_reply(reply):
            return "ERROR controller reset problem: %s" % reply[1]
        else:
            print("controller reset OK %d/%d" % (loop + 1, Cycles))
        time.sleep(1)
    print("*** Controller reset OK ***")

    # temperature
    if len(azcam.api.get_par("controller.utility_board")) > 0:
        print("\nTesting controller temperature readback...")
        for loop in range(Cycles):
            reply = azcam.api.get_temperatures()
            if azcam.utils.check_reply(reply):
                return "ERROR reading controller temperature: %s" % reply[1]
            else:
                print(
                    "Temperatures: %.1f %.1f %.1f: %d/%d"
                    % (reply[1], reply[2], reply[3], loop + 1, Cycles)
                )
        print("*** Temperature communication OK ***")

    print("\nController tests finished.")

    return


if __name__ == "__main__":
    args = sys.argv[1:]
    test_controller(*args)
