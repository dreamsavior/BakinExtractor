"""BakinExtractor CLI entrypoint.

Note: When packaged (e.g. via PyInstaller) on Windows, the default console
encoding may be a legacy code page (often cp1252). If the archive contains
non-ASCII filenames (JP/CN/etc), printing those names can raise
UnicodeEncodeError.

To make the CLI robust across consoles, we reconfigure stdout/stderr to UTF-8
when possible.
"""

from pack import pack
from unpack import unpack
from argparse import ArgumentParser
import sys


def _configure_utf8_console() -> None:
    # Python 3.7+: TextIOWrapper supports reconfigure(). Guard because stdout may
    # be replaced or missing in some packaged/no-console scenarios.
    for stream_name in ("stdout", "stderr"):
        stream = getattr(sys, stream_name, None)
        if stream is None:
            continue
        reconfigure = getattr(stream, "reconfigure", None)
        if callable(reconfigure):
            try:
                reconfigure(encoding="utf-8", errors="backslashreplace")
            except Exception:
                # If the host does not allow reconfiguration, just continue.
                pass


_configure_utf8_console()

parser = ArgumentParser()
subparsers = parser.add_subparsers(dest="verb")

parser_pack = subparsers.add_parser("pack")
parser_pack.add_argument("unpack_directory",type=str)
parser_pack.add_argument("packed_file_path",type=str)

parser_unpack = subparsers.add_parser("unpack")
parser_unpack.add_argument("rbpack_path",type=str)
parser_unpack.add_argument("output_directory",type=str)

args = parser.parse_args()
if args.verb == "pack":
    pack(args.unpack_directory,args.packed_file_path)
elif(args.verb == "unpack"):
    unpack(args.rbpack_path,args.output_directory)
else:
    parser.print_help()