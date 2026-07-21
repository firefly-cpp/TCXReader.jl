#!/usr/bin/env julia

using TCXReader

exit(TCXReader._cli_main(ARGS, stdout, stderr))
