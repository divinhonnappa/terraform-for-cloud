from flask import Flask, render_template
import sys

app = Flask(__name__)


@app.route("/")
def index():
    colors = dict()
    colors["aws"] = "FF9900"
    colors["azure"] = "007FFF"
    colors["google"] = "f4c20d"
    return render_template("index.html", cloud=sys.argv[1].upper(), color=colors[sys.argv[1]])


if __name__ == "__main__":
    if sys.argv[1] == "":
        exit()
    app.run(host="0.0.0.0", port=80, debug=False)
