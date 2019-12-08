import os
import sys

import azcam

# *******************************************************************************
# IPython stuff
# *******************************************************************************
def config_ipython():
    """
    Configure IPython, especially prompts.
    """

    # no warning if not using IPython
    try:
        azcam.db.ip = get_ipython()
    except NameError:
        return

    # ****************************************************************
    # prompts
    # ****************************************************************
    from IPython.terminal.prompts import Prompts, Token

    class MyPrompt(Prompts):
        def __init__(self, *args, **kwargs):
            super(MyPrompt, self).__init__(*args, **kwargs)

        def in_prompt_tokens(self, cli=None):
            return [(Token, os.getcwd()), (Token.Prompt, ">")]

        def out_prompt_tokens(self):
            return [(Token, ""), (Token.Prompt, "==>")]

    azcam.db.ip.prompts = MyPrompt(azcam.db.ip)

    # no command line seperator
    azcam.db.ip.separate_in = ""

    # Run command
    f1 = open(os.devnull, "w")  # disable annoying print statements in IPython
    f2 = sys.stdout
    sys.stdout = f1
    azcam.db.ip.magic("alias_magic Run run -p '-m'")
    sys.stdout = f2

    return
