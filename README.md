List Erlang Deps for App
========================

How to use
----------
1.  Requirements.

    To use List Erlang Deps for App you need:
    *   Erlang/OTP R17.X

2.  Running List Erlang Deps for App.

```bash
escript list-erlang-deps-for-app.escript  --help
Usage: list-erlang-deps-for-app.escript
[-c [<cwd>]] [-o [<output>]] [files ...]

-c, --cwd     Main application root directory [default: .]
-o, --output  Desired output format, either erlang or bash [default:
            bash]
files         Optional list of .app.src files to parse instead of
            automatically finding them in cwd
```
