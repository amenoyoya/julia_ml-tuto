"""
PyCall + Flask によるWebサーバー動作テスト
- Juliaでは動作させられない: EXCEPTION_ACCESS_VIOLATION例外が発生する
"""
using PyCall
const flask = pyimport_conda("flask", "flask")

const app = flask.Flask("pycall/flask")

app.route("/", methods=["GET"])(function()
    return "Hello, world", 200
end)
app.run(port=3000)
